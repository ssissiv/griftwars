local Wait = class( "Verb.Wait", Verb )

function Wait:GetDesc()
	return "Wait"
end

function Wait:CanInteract( actor )
	return Verb.CanInteract( self, actor )
end

function Wait:Interact( actor )	
	if actor:InCombat() then
		self:YieldForTime( ATTACK_TIME )
	else
		self:YieldForTime( HALF_HOUR, "wall", 1.0 )
	end
end
