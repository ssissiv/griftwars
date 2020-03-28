local Structure = class( "Structure", Object )

-- function Structure:CollectVerbs( verbs, actor, obj )
-- 	if obj == self then
-- 		verbs:AddVerb( Verb.LeaveLocation( actor, self.exit:GetDest( self.location )))
-- 	end
-- end

function Structure:Connect( dest )
	assert( self.location )
	self.exit = self.location:Connect( dest, self )

	local door = Object.Door()
	door:WarpToLocation( self.location )

	local door = Object.Door()
	door:WarpToLocation( dest )
end


function Structure:GetName()
	if self.exit == nil then
		return "Nowwhere!"
	else
		return self.exit:GetDest( self.location )
	end
end