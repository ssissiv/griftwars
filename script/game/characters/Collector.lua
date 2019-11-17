
local Collector = class( "Agenda.Collector", Aspect.Agenda )

function Collector:init()
	Aspect.Agenda.init( self )
	self:RegisterHandler( AGENT_EVENT.CALC_AGENDA, self.OnCalculateAgenda )
end

function Collector:OnCalculateAgenda( event_name, agent, agenda )
	local subordinate
	for i, r in self.owner:Relationships() do
		if is_instance( r, Relationship.Subordinate ) and r.boss == self.owner and r.subordinate:HasAspect( Aspect.Behaviour ) then
			subordinate = r.subordinate
			break
		end
	end
	if subordinate then
		-- agenda:ScheduleTaskForAgenda( Verb.Idle( agent ), 21, 22, self )
		-- subordinate:GetAspect( Aspect.Agenda ):ScheduleTaskForAgenda( Verb.Deliver( subordinate, agent ), 14, 22, self )
		subordinate:GetAspect( Aspect.Behaviour ):AddBehaviour( Behaviour.Deliver( subordinate, agent ))
		DBG(subordinate)
	end
end

--------------------------------------------------------------------------------

function Agent.Collector()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
	ch:GainAspect( Agenda.Collector() )
 	return ch
end

