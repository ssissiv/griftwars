-- Portals connect Locations together.
-- They are 'matched' together according to worldgen_tag, which is a space-delimited string that functions
-- like the edge of a puzzle piece.

local Portal = class( "Aspect.Portal", Aspect )

function Portal:init( location, x, y )
	self:Connect( location, x, y )
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

function Portal:CollectVerbs( verbs, agent )
	if self.waypoint then
		verbs:AddVerb( Verb.LeaveLocation( self ))
	end
end

function Portal:__tostring()
	return string.format( "Aspect.Portal<%s>", tostring(self.waypoint))
end

