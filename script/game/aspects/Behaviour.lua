--------------------------------------------------------------------
-- Behaviours schedule Verb evaluation & execution every ONE_HOUR
--    CollectInteractions -> DoVerb

local Behaviour = class( "Aspect.Behaviour", Aspect )

function Behaviour:init()
	self.behaviours = {}
	self.priority = 0
end

function Behaviour:OnSpawn( world )
	self:ScheduleNextTick()
end

function Behaviour:GetPriority()
	return self.priority
end

function Behaviour:UpdatePriority()
	-- for i, behaviour in ipairs( self.behaviours ) do
	-- 	behaviour:UpdatePriority()
	-- end
end

function Behaviour:AddBehaviour( behaviour )
	table.insert( self.behaviours, behaviour )
end

function Behaviour:ScheduleNextTick()
	if self.tick_ev then
		self.owner.world:UnscheduleEvent( self.tick_ev )
	end
	local delta = math.randomGauss( 0.1 * ONE_HOUR, 0.1 * ONE_HOUR, ONE_HOUR / 60 )
	self.tick_ev = self.owner.world:ScheduleFunction( delta, self.TickBehaviour, self )
end

function Behaviour.SortBehaviour( a, b )
	return a.priority > b.priority
end

function Behaviour:TickBehaviour()
	-- First update priorities.
	for i, behaviour in ipairs( self.behaviours ) do
		behaviour:UpdatePriority()
	end

	table.sort( self.behaviours, self.SortBehaviour )

	--
	for i, behaviour in ipairs( self.behaviours ) do
		behaviour:RunBehaviour()
	end



	-- if not self.owner:IsBusy() then
	-- 	local verb = self.owner:GetPotentialVerbs():PickRandom()
	-- 	if verb then
	-- 		self.owner:DoVerb( verb )
	-- 	end
	-- end

	self:ScheduleNextTick()
end
