local Travel = class( "Verb.Travel", Verb )

function Travel:init( dest )
	Verb.init( self, nil, dest )
end

function Travel:SetApproachDistance( dist )
	self.approach_dist = dist
end

function Travel:GetDesc( viewer )
	if self.obj == viewer then
		return loc.format( "Approaching you!" )
	elseif is_instance( self.obj, Location ) then
		return loc.format( "Traveling to {1}", self.obj )
	elseif self.obj and self.obj.GetLocation then
		if viewer and self.obj:GetLocation() == viewer:GetLocation() then
			return loc.format( "Approaching {1}", tostring(self.obj) )
		else
			return loc.format( "Traveling to {1}", self.obj:GetLocation() )
		end
	end
	return "Traveling"
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

	while not pather:AtGoal() do

		self.path = pather:GetPath()
		self.pather = pather

		local ok, reason = false
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

			ok, reason = actor:Walk( dir )
			if not ok then
				-- Try a perpendicular direction.
				dir = table.arraypick( ADJACENT_DIR[ dir ] )
				ok, reason = actor:Walk( dir )
			end
		end

		if not ok then				
			-- Finally, we just fail.
			self.block_count = (self.block_count or 0) + 1
			print( actor, "couldn't walk:", reason, self.block_count, tostr(self.path) )
			if self.block_count >= 3 then
				pather:ResetPath()
			end

			self:YieldForTime( ONE_SECOND * self.block_count * self.block_count )
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

function Travel:Interact( actor, dest )
	dest = self:SetTarget( dest or self.obj )
	assert( dest )

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
			print( actor, "Overworld path found, but can't find or access portal!", self.fail_count )
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

	-- At the destination Location, now go to a specific tile.
	if is_instance( dest, Waypoint ) or is_instance( dest, Agent ) or is_instance( dest, Object ) then
		self:PathToTarget( actor, dest, self.approach_dist )
	else
		-- Pick a random tile?
		local tile_dest = dest:FindEmptyPassableTile( nil, nil, actor )
		self:PathToTarget( actor, tile_dest, self.approach_dist )
	end
end

---------------------------------------------------------------

