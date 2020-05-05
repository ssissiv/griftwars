local Wait = class( "Verb.Wait", Verb )

function Wait:GetDesc()
	return "Wait"
end

function Wait:CanInteract( actor )
	if actor:InCombat() then
		return false, "You're in the middle of combat!"
	end
	return true
end

function Wait:Interact( actor )	
	self:YieldForTime( HALF_HOUR )
end
