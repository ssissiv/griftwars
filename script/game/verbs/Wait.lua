local Wait = class( "Verb.Wait", Verb )

Wait.act_desc = "Wait"

function Wait:CanInteract( actor )
	return Verb.CanInteract( self, actor )
end

function Wait:Interact( actor )	
	if actor:InCombat() then
		self:YieldForTime( ATTACK_TIME, "instant" )
	else
		self:YieldForTime( HALF_HOUR, "wall", 1.0 )
	end
end
