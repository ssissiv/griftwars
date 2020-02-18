local Structure = class( "Structure", Object )

-- function Structure:CollectVerbs( verbs, actor, obj )
-- 	if obj == self then
-- 		verbs:AddVerb( Verb.LeaveLocation( actor, self.exit:GetDest( self.location )))
-- 	end
-- end

function Structure:Connect( dest )
	assert( self.location )
	self.exit = self.location:Connect( dest, self )
end


function Structure:GetName()
	return loc.format( "Structure ({1})", self.exit:GetDest( self.location ))
end