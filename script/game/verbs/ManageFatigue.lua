local ManageFatigue = class( "Verb.ManageFatigue", Verb )

function ManageFatigue:init( actor )
	ManageFatigue._base.init( self, actor )
	self.rest = self:AddChildVerb( Verb.ShortRest( actor ))
	self.sleep = self:AddChildVerb( Verb.Sleep( actor ))
end

function ManageFatigue:UpdatePriority( actor, priority )
	if self.sleep:IsDoing() or self.rest:IsDoing() then
		priority = PRIORITY.EMERGENCY - 10
	else
		local night_t = Calendar.GetNormalizedTimeOfDay( actor.world:GetDateTime(), 20 * ONE_HOUR )
		if night_t > 0.8 then
			priority = PRIORITY.HABIT
		else
			priority = PRIORITY.FUN
		end

		local t = actor:GetStat( STAT.FATIGUE ):GetPercent()
		priority = priority + Easing.inQuad( t, 0, PRIORITY.EMERGENCY - priority, 1.0 )
	end

	return priority
end

function ManageFatigue:Interact( actor )
	Msg:Speak( actor, "I'm sleepy..." )
	if Calendar.IsNight( actor.world:GetDateTime() ) then
		self.sleep:DoVerb( actor )
	else
		self.rest:DoVerb( actor )
	end
	self:YieldForTime( ONE_MINUTE )
end
