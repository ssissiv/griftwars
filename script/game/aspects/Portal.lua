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

function Portal:MatchWorldGenTag( tag )
	return self.worldgen_tag == tag
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

