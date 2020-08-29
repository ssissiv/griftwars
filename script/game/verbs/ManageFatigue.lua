local ManageFatigue = class( "Verb.ManageFatigue", Verb.Plan )

function ManageFatigue:init( actor )
	ManageFatigue._base.init( self, actor )
	self.rest = Verb.ShortRest( actor )
	self.sleep = Verb.Sleep( actor )
	self.travel = Verb.Travel( actor )
end

function ManageFatigue:CollectVerbs( verbs, actor, obj )
	if actor == self.owner and obj == actor then
		verbs:AddVerb( Verb.ShortRest( actor ))
	end
end

function ManageFatigue:CalculateUtility()
	local actor = self.actor
	local fatigue =	actor:GetStat( STAT.FATIGUE ):GetPercent()

	if fatigue > 0.9 then
		return UTILITY.EMERGENCY

	elseif not actor:InCombat() then
		if actor:GetSpeciesProps().nocturnal then
			if not Calendar.IsDay( actor.world:GetDateTime() ) then
				return 0, "Not day"
			end
			return UTILITY.HABIT

		else
			if not Calendar.IsNight( actor.world:GetDateTime() ) then
				return 0, "Not night"
			end
			return UTILITY.HABIT
		end
	end

	return 0
end

function ManageFatigue:Interact()
	local actor = self.actor
	local fatigue =	actor:GetStat( STAT.FATIGUE ):GetPercent()
	local nocturnal = actor:GetSpeciesProps().nocturnal
		
	if (nocturnal and Calendar.IsDay( actor.world:GetDateTime())) or
			(not nocturnal and Calendar.IsNight( actor.world:GetDateTime())) then
		--
		Msg:Speak( actor, "I'm sleepy..." )
		local home = actor:GetHome()
		if home then
			Msg:Speak( actor, "I'm going home." )
			self.travel:SetDest( home )
			self:DoChildVerb( self.travel )
		end

		-- NOTE: if actor gets too tired on the way, they'll just sleep where they are for now.
		self:DoChildVerb( self.sleep )

	else
		self:DoChildVerb( self.rest )
	end

	-- failsafe?
	-- if not self:IsCancelled() then
	-- 	self:YieldForTime( ONE_MINUTE )
	-- end
end
