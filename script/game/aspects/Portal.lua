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

function Portal:Connect( location, x, y )
	if location == nil then
		self.waypoint = nil
	else
		self.waypoint = Waypoint( location, x, y )
	end
end

function Portal:GetLocation()
	return self.owner:GetLocation()
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

function Portal:CollectVerbs( verbs, actor, obj )
	if self.waypoint and obj == self.owner then
		verbs:AddVerb( Verb.LeaveLocation( self ))
	end
end

function Portal:__tostring()
	return string.format( "Aspect.Portal<%s>", tostring(self.waypoint))
end

