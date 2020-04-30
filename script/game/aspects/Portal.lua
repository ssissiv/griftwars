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
	local tags = tagstr and tagstr:split( " " )
	if tags == nil or #tags == 0 then
		return false
	end
	local our_tags = self.worldgen_tag:split( " " )
	if our_tags == nil or #our_tags == 0 then
		return false
	end

	-- All incoming tags must match.
	for i, tag in ipairs( tags ) do
		tag = MATCH_TAGS[ tag ] or tag
		if not table.contains( our_tags, tag ) then
			return false
		end
	end

	-- All our tags must match to incoming.
	for i, tag in ipairs( our_tags ) do
		tag = MATCH_TAGS[ tag ] or tag
		if not table.contains( tags, tag ) then
			return false
		end
	end

	return true
end

function Portal:Connect( location, x, y )
	if location == nil then
		self.waypoint = nil
	else
		self.waypoint = Waypoint( location, x, y )
	end
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

