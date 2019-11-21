local ManageFatigue = class( "Verb.ManageFatigue", Verb )

function ManageFatigue:init()
	ManageFatigue._base.init( self )
	self.sleep = Verb.Sleep()
end

function ManageFatigue:UpdatePriority( actor, priority )
	local night_t = Calendar.GetNormalizedTimeOfDay( actor.world:GetDateTime(), 20 * ONE_HOUR )
	if night_t > 0.8 then
		priority = PRIORITY.HABIT
	else
		priority = PRIORITY.FUN
	end

	local t = actor:GetStat( STAT.FATIGUE ):GetPercent()
	priority = priority + Easing.inQuad( t, 0, PRIORITY.EMERGENCY - priority, 1.0 )
	return priority
end

function ManageFatigue:Interact( actor )
	Msg:Speak( actor, "I'm sleepy..." )
	self.sleep:DoVerb( actor )
	self:YieldForTime( ONE_MINUTE )
end
