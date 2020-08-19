-- Portals connect Locations together.
-- They are 'matched' together according to worldgen_tag, which is a space-delimited string that functions
-- like the edge of a puzzle piece.

local Portal = class( "Aspect.Portal", Aspect )

function Portal:init( travel_time )
	self.travel_time = travel_time or TRAVEL_TIME
end

function Portal:GetTravelTime()
	return self.travel_time
end

function Portal:IsOneWay()
	return false
end

function Portal:OnDespawn()
	Aspect.OnDespawn( self )

	-- Disconnect the reverse reference.
	if self.reverse_portal then
		assert( self.reverse_portal.reverse_portal == self )
		self.reverse_portal.reverse_portal = nil
	end
end


function Portal:WarpToDest( actor )
	-- Warp to dest Location.
	local dest, destx, desty = self:GetDest()
	
	Msg:EchoAround( actor, "{1.Id} leaves to {2.title}.", actor, dest )

	actor:DeltaStat( STAT.FATIGUE, 5 )

	local entry_tile = dest:FindPassableTile( destx, desty, actor )
	if entry_tile then
		actor:WarpToLocation( dest, entry_tile:GetCoordinate() )

		Msg:EchoTo( actor, "You enter {1}.", dest:GetTitle() )
		Msg:EchoAround( actor, "{1.Id} enters.", actor )
	else
		Msg:EchoTo( actor, "The other side seems to be blocked!" )
		print( actor, "couldn't leave to", dest )
		DBG( dest:LookupTile( destx, desty ))
	end
end

function Portal:CanUsePortal( actor )
	if self.owner.CanUsePortal then
		return self.owner:CanUsePortal( actor )
	end

	return true
end

function Portal:ActivatePortal( verb )
	if self.owner.OnActivatePortal and self.owner:OnActivatePortal( self, verb ) then
		return
	end

	verb:YieldForTime( self.travel_time )

	if verb:IsCancelled() then
		return
	end		

	self:WarpToDest( verb.actor )
end

function Portal:SetWorldGenTag( tag )
	self.worldgen_tag = tag
end

function Portal:GetWorldGenTag()
	return self.worldgen_tag
end

function Portal:HasWorldGenTag( tagstr )
	return self.worldgen_tag and self.worldgen_tag:find(tagstr) ~= nil
end

function Portal:MatchWorldGenTag( tagstr )
	return WorldGen.MatchWorldGenTag( self.worldgen_tag, tagstr )
end

function Portal:GetExitFromTag()
	for i, exit in ipairs( EXIT_ARRAY ) do
		if self:HasWorldGenTag( EXIT_TAG[ exit ] ) then
			return exit
		end
	end
end

function Portal:IsExitOccupied()
	local exit = self:GetExitFromTag()
	if exit then
		local wx, wy, wz = self:GetLocation():GetCoordinate()
		wx, wy = OffsetExit( wx, wy, exit )
		if self:GetWorld():GetWorldMap():LookupTile( wx, wy, wz ) then
			return true
		end
	end

	return false
end

function Portal:Connect( location, x, y, reverse_portal )
	if location == nil then
		self.waypoint = nil
	else
		assert( x and y )
		self.waypoint = Waypoint( location, x, y )
	end

	if self.owner.OnConnected then
		self.owner:OnConnected( reverse_portal.owner )
	end
end

function Portal:ConnectPortal( portal )
	local location = portal:GetLocation()
	local x, y = portal.owner:GetCoordinate()
	assert( location and x and y, tostring(portal.owner))

	self:Connect( location, x, y, portal )

	x, y = self.owner:GetCoordinate()
	portal:Connect( self:GetLocation(), x, y, self )
end

function Portal:GetLocation()
	return self.owner:GetLocation()
end

function Portal:GetDestEntity()
	return self.reverse_portal and self.reverse_portal.owner
end

function Portal:GetDest()
	if self.waypoint then
		return self.waypoint:GetDest()
	end
end

function Portal:OnLocationChanged( prev_location, location )
	if prev_location then
		prev_location:RemovePortal( self )
	end
	if location then
		location:AddPortal( self )
	end
end

function Portal:__tostring()
	return string.format( "Aspect.Portal<%s>", tostring(self.waypoint))
end

