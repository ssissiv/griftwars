local Travel = class( "Verb.Travel", Verb )

-- Travel.FLAGS = VERB_FLAGS.MOVEMENT


Travel.EXIT_STRINGS =
{
	"You leave {2.title}.",
	nil,
	"{1.Id} leaves.",
}

Travel.ENTER_STRINGS =
{
	"You enter {2.title}.",
	nil,
	"{1.Id} enters."
}

function Travel:init( dest )
	Verb.init( self, nil, dest )
	self.leave = self:AddChildVerb( Verb.LeaveLocation() )
end

function Travel:SetApproachDistance( dist )
	self.approach_dist = dist
end

function Travel:GetDesc()
	return loc.format( "Travel to {1}", tostring(self.obj) )
end

function Travel:RenderAgentDetails( ui, screen, viewer )
	if viewer:CanSee( self.actor ) then
		ui.Bullet()
		ui.Text( loc.format( "Traveling to {1}", tostring(self.obj) ))
	end
end

function Travel:CanInteract( actor )
	if not actor:IsAlert() then
		return false, "Not Alert"
	end
	if not actor:IsSpawned() then
		return false
	end
	-- if actor:InCombat() then
	-- 	return false, "In combat"
	-- end
	return true
end

function Travel:PathToTarget( actor, dest )
	local pather = TilePathFinder( actor, actor, dest, self.approach_dist )

	while true do

		self.path = pather:GetPath()

		if self.path and #self.path >= 2 then
			local x1, y1 = self.path[1]:GetCoordinate()
			local x2, y2 = self.path[2]:GetCoordinate()
			local dir = OffsetToDir( x1, y1, x2, y2 )
			actor:Walk( dir )
		else
			break
		end

		-- Path available.  Time to wait.
		if actor:IsRunning() then
			actor:DeltaStat( STAT.FATIGUE, 2 )
			self:YieldForTime( RUN_TIME, "rate", 8.0 )
		else
			self:YieldForTime( WALK_TIME, "rate", 8.0 )
		end

		if self:IsCancelled() then
			break
		end

		if pather:AtGoal() then
			break
		end
	end

	return actor:GetTile() == pather:GetEndRoom()
end

function Travel:PathToDest( actor, location )
	-- Find a portal to this location.
	for i, portal in actor.location:Portals() do
		if portal:GetDest() == location and portal.owner:GetTile() then
			-- Path tiles to dest.
			if self:PathToTarget( actor, portal ) then
				actor:WarpToLocation( portal:GetDest() )
				break

			elseif self:IsCancelled() then
				break
			end
		end
	end
end

function Travel:Interact( actor, dest )
	dest = dest or self.obj
	assert( dest )

	local pather = PathFinder( actor, dest )
	while actor:GetLocation() ~= pather:GetEndRoom() do

		if self:IsCancelled() then
			break
		end

		self.path = pather:GetPath()
		if self.path then
			local portal = actor:GetLocation():FindPortalTo( self.path[2] )
			local ok, reason = self.leave:DoVerb( actor, portal )
			if not ok then
				print( "Cant travel", actor, reason )
				self:YieldForTime( HALF_HOUR )
			end
		else
			print( "No path!", actor, dest )
			self:YieldForTime( HALF_HOUR )
		end
	end

	-- uh... 
	if is_instance( dest, Waypoint ) or is_instance( dest, Agent ) or is_instance( dest, Object ) then
		local x, y = AccessCoordinate( dest )
		if x and y then
			self:PathToTarget( actor, dest )
		end
	end
end

---------------------------------------------------------------

