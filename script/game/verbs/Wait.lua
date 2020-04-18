local Wait = class( "Verb.Wait", Verb )
Wait.ACT_RATE = 16.0

function Wait:GetDesc()
	return "Wait"
end

function Wait:Interact( actor )	
	self:YieldForTime( HALF_HOUR )
end
