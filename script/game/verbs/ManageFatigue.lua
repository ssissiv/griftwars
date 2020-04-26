local ManageFatigue = class( "Verb.ManageFatigue", Verb )

function ManageFatigue:init()
	ManageFatigue._base.init( self )
	self.rest = self:AddChildVerb( Verb.ShortRest())
	self.sleep = self:AddChildVerb( Verb.Sleep())
	self.travel = self:AddChildVerb( Verb.Travel())
end

function ManageFatigue:CalculateUtility( actor )
	local utility
	if self.sleep:IsDoing() then
		utility = UTILITY.EMERGENCY - 10
	elseif self.rest:IsDoing() then
		utility = UTILITY.FUN
	else
		local night_t = Calendar.GetNormalizedTimeOfDay( actor.world:GetDateTime(), 20 * ONE_HOUR )
		if night_t > 0.8 then
			utility = UTILITY.HABIT
		else
			utility = UTILITY.FUN
		end

		local t = actor:GetStat( STAT.FATIGUE ):GetPercent()
		if t < 0.2 then
			utility = 0
		else
			utility = utility + Easing.inQuad( t, 0, UTILITY.EMERGENCY - utility, 1.0 )
		end
	end

	return utility
end

function ManageFatigue:Interact( actor )
	Msg:Speak( actor, "I'm sleepy..." )
	if Calendar.IsNight( actor.world:GetDateTime() ) then
		local home = actor:GetHome()
		if home then
			Msg:Speak( actor, "I'm going home." )
			self.travel:DoVerb( actor, home )
		end

		if home and actor:GetLocation() == home then
			self:GetWorld():Log( "{1} is sleeping at home.", actor )
		end

		self.sleep:DoVerb( actor )
	else
		self.rest:DoVerb( actor )
	end
	self:YieldForTime( ONE_MINUTE )
end
