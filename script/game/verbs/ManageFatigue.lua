local ManageFatigue = class( "Verb.ManageFatigue", Verb.Plan )

function ManageFatigue:init()
	ManageFatigue._base.init( self )
	self.rest = Verb.ShortRest()
	self.sleep = Verb.Sleep()
	self.travel = Verb.Travel()
end

function ManageFatigue:CalculateUtility( actor )
	local utility
	if self.sleep:IsDoing() or self.rest:IsDoing() then
		utility = UTILITY.EMERGENCY - 10

	else
		local night_t = Calendar.GetNormalizedTimeOfDay( actor.world:GetDateTime(), 1 * ONE_HOUR )
		if actor:GetSpeciesProps().nocturnal then
			if night_t > 0.7 then
				utility = UTILITY.HABIT
				return utility
			else
				utility = UTILITY.FUN
			end
		else
			if night_t > 0.8 then
				utility = UTILITY.HABIT
				return utility
			else
				utility = UTILITY.FUN
			end
		end

		local t = actor:GetStat( STAT.FATIGUE ):GetPercent()
		if t < 0.5 then
			utility = 0
		else
			utility = utility + Easing.inQuad( t, 0, UTILITY.EMERGENCY - utility, 1.0 )
		end
	end
	return utility
end

function ManageFatigue:Interact( actor )
	if Calendar.IsNight( actor.world:GetDateTime() ) then
		Msg:Speak( actor, "I'm sleepy..." )
		local home = actor:GetHome()
		if home then
			Msg:Speak( actor, "I'm going home." )
			self:DoChildVerb( self.travel, home )
		end

		if home and actor:GetLocation() == home then
			self:GetWorld():Log( "{1} is sleeping at home.", actor )
		end

		self:DoChildVerb( self.sleep, actor )

	else
		Msg:Speak( actor, "Maybe I'll rest for a bit." )
		self:DoChildVerb( self.rest, actor )
	end

	if not self:IsCancelled() then
		self:YieldForTime( ONE_MINUTE )
	end
end
