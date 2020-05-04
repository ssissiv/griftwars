local Wait = class( "Verb.Wait", Verb )
Wait.ACT_RATE = 16.0

function Wait:GetDesc()
	return "Wait"
end

function Wait:CanInteract( actor )
	if false and actor:InCombat() then
		return false, "You're in the middle of combat!"
	end
	return true
end

function Wait:Interact( actor )	
	self:YieldForTime( HALF_HOUR )
end
