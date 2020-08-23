local ManageFatigue = class( "Verb.ManageFatigue", Verb.Plan )

function ManageFatigue:init( actor )
	ManageFatigue._base.init( self, actor )
	self.rest = Verb.ShortRest( actor )
	self.sleep = Verb.Sleep( actor )
	self.travel = Verb.Travel( actor )
end

function ManageFatigue:CalculateUtility()
	local actor = self.actor
	local fatigue =	actor:GetStat( STAT.FATIGUE ):GetPercent()

	if fatigue > 0.9 then
		return UTILITY.EMERGENCY

	elseif actor:GetSpeciesProps().nocturnal then
		if not Calendar.IsDay( actor.world:GetDateTime() ) then
			return 0, "Not day"
		end
		if actor:InCombat() then
			return 0, "In combat"
		end
		return UTILITY.HABIT

	else
		if not Calendar.IsNight( actor.world:GetDateTime() ) then
			return 0, "Not night"
		end
		if actor:InCombat() then
			return 0, "In combat"
		end
		return UTILITY.HABIT
	end

	return 0
end

function ManageFatigue:Interact()
	local actor = self.actor
	if Calendar.IsNight( actor.world:GetDateTime() ) then
		Msg:Speak( actor, "I'm sleepy..." )
		local home = actor:GetHome()
		if home then
			Msg:Speak( actor, "I'm going home." )
			self.travel:SetDest( home )
			self:DoChildVerb( self.travel )
		end

		if home and actor:GetLocation() == home then
			self:GetWorld():Log( "{1} is sleeping at home.", actor )
		end

		self:DoChildVerb( self.sleep )

	else
		Msg:Speak( actor, "Maybe I'll rest for a bit." )
		self:DoChildVerb( self.rest )
	end

	if not self:IsCancelled() then
		self:YieldForTime( ONE_MINUTE )
	end
end
