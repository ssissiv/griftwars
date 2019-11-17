local ManageFatigue = class( "Behaviour.ManageFatigue", Aspect.Behaviour )

function ManageFatigue:init()
	ManageFatigue._base.init( self )
	self.sleep = self:AddVerb( Verb.Sleep())
end

function ManageFatigue:CalculatePriority( world )
	local priority
	local night_t = Calendar.GetNormalizedTimeOfDay( world:GetDateTime(), 20 * ONE_HOUR )
	if night_t > 0.8 then
		priority = PRIORITY.HABIT
	else
		priority = PRIORITY.FUN
	end

	local t = self.owner:GetStat( STAT.FATIGUE ):GetPercent()
	priority = priority + Easing.outQuad( t, 0, PRIORITY.EMERGENCY, 1.0 )
	return priority
end

function ManageFatigue:RunBehaviour()
	Msg:Speak( self.owner, "I'm sleepy..." )
	self.owner:DoVerb( self.sleep )
end
