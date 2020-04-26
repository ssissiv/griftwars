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

function Travel:GetDesc()
	return loc.format( "Travel to {1}", tostring(self.obj) )
end

function Travel:RenderAgentDetails( ui, screen, viewer )
	if viewer:CanSee( self.owner ) then
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
	if actor:InCombat() then
		return false, "In combat"
	end
	return true
end

function Travel:PathToTile( actor, tile )
	local pather = TilePathFinder( actor, actor, tile )
	while actor:GetTile() ~= tile do
		self:YieldForTime( 4 * ONE_SECOND )

		if self:IsCancelled() then
			break
		end

		local path = pather:CalculatePath()
		if path then
			local x1, y1 = path[1]:GetCoordinate()
			local x2, y2 = path[2]:GetCoordinate()
			local exit = OffsetToExit( x1, y1, x2, y2 )
			actor:Walk( exit )
		else
			break
		end
	end

	return actor:GetTile() == tile
end

function Travel:PathToDest( actor, location )
	-- Find a portal to this location.
	for i, portal in actor.location:Portals() do
		if portal:GetDest() == location and portal.owner:GetTile() then
			-- Path tiles to dest.
			local tile = portal.owner:GetTile()
			if self:PathToTile( actor, tile ) then
				actor:WarpToLocation( portal:GetDest() )
				break

			elseif self:IsCancelled() then
				break
			end
		end
	end
end

function Travel:Interact( actor, dest )
	if dest then
		self.obj = dest
	end
	local pather = PathFinder( actor, self.obj )
	while actor:GetLocation() ~= pather:GetEndRoom() do

		if self:IsCancelled() then
			break
		end

		local path = pather:CalculatePath()
		if path then
			self:PathToDest( path[2] )
		end
	end

	if is_instance( dest, Waypoint ) then
		local x, y = dest:GetCoordinate()
		local tile = actor.location:GetTileAt( x, y )
		self:PathToTile( actor, tile )
	end
end

---------------------------------------------------------------

