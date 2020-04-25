local Portal = class( "Aspect.Portal", Aspect )

function Portal:init( location, x, y )
	self:Connect( location, x, y )
	self.leave_verb = Verb.LeaveLocation( self )
end

function Portal:SetWorldGenTag( tag )
	self.worldgen_tag = tag
end

function Portal:GetWorldGenTag()
	return self.worldgen_tag
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
	self.location, self.x, self.y = location, x, y
	if location then
		assert( location ~= self.owner.location )
	end
end

function Portal:GetDest()
	return self.location, self.x, self.y
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
	if self.location then
		verbs:AddVerb( Verb.LeaveLocation( self ))
	end
end

