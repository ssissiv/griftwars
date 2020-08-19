local Travel = class( "Verb.Travel", Verb )

function Travel:init( actor, dest )
	Verb.init( self, actor )
	self.dest = dest
	self.walk = Verb.Walk( actor )
end

function Travel:SetDest( dest )
	self.dest = dest
end

function Travel:SetApproachDistance( dist )
	self.approach_dist = dist
end

function Travel:GetActDesc()
	return "Travel"
end

function Travel:GetDesc( viewer )
	if self.dest == viewer then
		return loc.format( "Approaching you!" )
	elseif is_instance( self.dest, Location ) then
		return loc.format( "Traveling to {1}", self.dest )
	elseif self.dest and self.dest.GetLocation then
		if viewer and self.dest:GetLocation() == viewer:GetLocation() then
			return loc.format( "Approaching {1}", tostring(self.dest) )
		else
			return loc.format( "Traveling to {1}", self.dest:GetLocation() )
		end
	end
	return "Traveling"
end

function Travel:CanInteract()
	local actor = self.actor
	if not actor:IsAlert() then
		return false, "Not Alert"
	end
	if not actor:IsSpawned() then
		return false
	end
	-- if actor:InCombat() then
	-- 	return false, "In combat"
	-- end
	return Verb.CanInteract( self, actor )
end

function Travel:FindDirToPath( actor, path )
	local x1, y1 = actor:GetCoordinate()
	for i = #path, 1, -1 do
		local tile = path[i]
		local x2, y2 = tile:GetCoordinate()
		if IsAdjacentCoordinate( x1, y1, x2, y2 ) then
			return OffsetToDir( x1, y1, x2, y2 )
		end
	end
end

function Travel:PathToTarget( actor, dest, approach_dist )
	local pather = TilePathFinder( actor, actor, dest, approach_dist )
	self.block_count = 0

	while pather:GetEndRoom() and not pather:AtGoal() do

		self.path = pather:GetPath()
		self.pather = pather

		local ok, reason = false, "no path"
		if self.path and #self.path > 0 then
			-- Find out which direction to walk:
			-- (a) If we're on the path follow it.
			-- (b) If we're off the path, can we get back on it?
			local path_idx = table.arrayfind( self.path, actor:GetTile() )
			local dir
			if path_idx and self.path[ path_idx + 1 ] then
				local x1, y1 = self.path[ path_idx ]:GetCoordinate()
				local x2, y2 = self.path[ path_idx + 1 ]:GetCoordinate()
				dir = OffsetToDir( x1, y1, x2, y2 )
			else
				dir = self:FindDirToPath( actor, self.path )
			end

			if dir then
				self.walk:SetDirection( dir )
				ok, reason = self:DoChildVerb( self.walk )
			end
			if not ok and dir then
				-- Try both perpendicular directions.
				local adir = table.arraypick( ADJACENT_DIR[ dir ] )
				self.walk:SetDirection( adir )
				ok, reason = self:DoChildVerb( self.walk )

				if not ok then
					adir = ADJACENT_DIR[ dir ][1] == adir and ADJACENT_DIR[ dir ][2] or ADJACENT_DIR[ dir ][1]
					self.walk:SetDirection( adir )
					ok, reason = self:DoChildVerb( self.walk )
				end
			end
		end

		if not ok then				
			-- Finally, we just fail.
			self.block_count = (self.block_count or 0) + 1
			-- print( actor, "couldn't walk:", reason, "blocked:", self.block_count )
			-- print( "At:", actor:GetTile(), actor:GetLocation() )
			-- print( "Goal:", dest, pather:GetEndRoom(), pather:AtGoal() )
			-- print( "Path:", tostr(self.path) )
			if self.block_count >= 3 then
				pather:ResetPath()
			end

			self:YieldForTime( ONE_SECOND * self.block_count * self.block_count )
			break
		end

		if self:IsCancelled() then
			break
		end
	end

	return actor:GetTile() == pather:GetEndRoom()
end

function Travel:PathToLocation( actor, location )
	-- Find a portal to this location.
	for i, portal in actor.location:Portals() do
		if portal:GetDest() == location and portal.owner:GetTile() then
			-- Path tiles to dest.
			local ok = self:PathToTarget( actor, portal )
			if self:IsCancelled() then
				break
			elseif ok then
				portal:ActivatePortal( self )
				break
			end
		end
	end

	return actor:GetLocation() == location
end

function Travel:Interact()
	local actor, dest = self.actor, self.dest
	local pather = PathFinder( actor, actor, dest )
	while actor:GetLocation() ~= pather:GetEndRoom() do

		if self:IsCancelled() then
			break
		end

		self.path = pather:CalculatePath()
		if not self.path then
			print( actor, "No path!", dest )
			self.fail_count = (self.fail_count or 0) + 1
			self:YieldForTime( ONE_MINUTE * self.fail_count )

		elseif not self:PathToLocation( actor, self.path[2] ) then
			print( actor, "Overworld path found, but can't find or access portal to!", dest )
			print( "At:", actor:GetTile() )
			print( "Fail:", self.fail_count )
			self.fail_count = (self.fail_count or 0) + 1
			self:YieldForTime( ONE_MINUTE * self.fail_count )

		else
			self.fail_count = nil
			if actor:GetLocation() ~= pather:GetEndRoom() then
				-- this needed? safety valve.
				self:YieldForTime( ONE_SECOND )
			end
		end
	end

	if is_instance( dest, Location ) then
		-- TODO: maybe this is valid, but it can pick unreachable tiles.

		-- Pick a random tile?
		-- local tile_dest = dest:FindEmptyPassableTile( nil, nil, actor )
		-- assert( tile_dest, tostring(dest))
		-- self:PathToTarget( actor, tile_dest, self.approach_dist )
	else
		self:PathToTarget( actor, dest, self.approach_dist )
	end
end

---------------------------------------------------------------

