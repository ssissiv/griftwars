local ManageFatigue = class( "Verb.ManageFatigue", Verb )

function ManageFatigue:init( actor )
	ManageFatigue._base.init( self, actor )
	self.rest = self:AddChildVerb( Verb.ShortRest( actor ))
	self.sleep = self:AddChildVerb( Verb.Sleep( actor ))
	self.travel = self:AddChildVerb( Verb.Travel( actor ))
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
		utility = utility + Easing.inQuad( t, 0, UTILITY.EMERGENCY - utility, 1.0 )
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
