local Wait = class( "Verb.Wait", Verb )

Wait.act_desc = "Wait"

function Wait:Interact()	
	if self.actor:InCombat() then
		self:YieldForTime( ATTACK_TIME, "instant" )
	else
		self.actor:GetStat( STAT.FATIGUE ):DeltaRegen( -50 )

		self:YieldForTime( HALF_HOUR, "wall", 1.0 )

		self.actor:GetStat( STAT.FATIGUE ):DeltaRegen( 50 )
	end
end
