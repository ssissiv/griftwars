local Collector = class( "Agenda.Collector", Aspect.Agenda )

function Collector:OnCollectAgenda( orders )
	for i, follower in ipairs( self.followers ) do
		if follower:GetInventory():CalculateValue() > 0 then
			table.insert( orders, Verb.OrderGive( self.owner, follower ))
		end
	end
end

function Collector:init()
	Aspect.Agenda.init( self )
	self:RegisterHandler( AGENT_EVENT.CALC_AGENDA, self.OnCalculateAgenda )
end

function Collector:OnCalculateAgenda( event_name, agent, agenda )
	local subordinate
	for i, other in self.owner:Relationships() do
		if other:HasAspect( Aspect.Scavenger ) then
			subordinate = other
			break
		end
	end
	if subordinate then
		agenda:ScheduleTaskForAgenda( Verb.CollectorExchange( agent, subordinate ), 9, 10 )
	end
end

--------------------------------------------------------------------------------

function Agent.Collector()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
	ch:GainAspect( Agenda.Collector() )
	ch:GainAspect( Aspect.Behaviour() )
 	return ch
end

