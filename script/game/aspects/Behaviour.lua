---------------------------------------------------------------
-- Behaviours make agents do things.

local Behaviour = class( "Aspect.Behaviour", Aspect )

function Behaviour:OnSpawn( world )
	world:SchedulePeriodicFunction( 0.1 * ONE_HOUR, self.TickBehaviour, self )
end

function Behaviour:TickBehaviour()
	if self.owner:IsBusy() then
		return
	end

	local verbs = self.owner:CollectInteractions()

	local verb = table.arraypick( verbs )
	if verb then
		verb:BeginActing()
	end
end
