--------------------------------------------------------------------
-- Behaviours schedule Verb evaluation & execution every ONE_HOUR
--    CollectInteractions -> DoVerb

local Behaviour = class( "Aspect.Behaviour", Aspect )

function Behaviour:OnSpawn( world )
	self:ScheduleNextTick()
end

function Behaviour:ScheduleNextTick()
	if self.tick_ev then
		self.owner.world:UnscheduleEvent( self.tick_ev )
	end
	local delta = math.randomGauss( 0.1 * ONE_HOUR, 0.1 * ONE_HOUR, ONE_HOUR / 60 )
	self.tick_ev = self.owner.world:ScheduleFunction( delta, self.TickBehaviour, self )
end

function Behaviour:TickBehaviour()
	if not self.owner:IsBusy() then
		local verb = self.owner:GetPotentialVerbs():PickRandom()
		if verb then
			self.owner:DoVerb( verb )
		end
	end

	self:ScheduleNextTick()
end
