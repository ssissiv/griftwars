--[[
	I deliver local news to and junk to the Collector in exchange for money.
	I spend coin on food, drink.
	I sleep on the streets.

	Want( Money )
	Want( Bed )
	Want( Rumors )
	Offer( Junk )
	Offer( Rumors )

	Aspect.Want( Money ) =>
		Verb.Scavenge (small value)
		Verb.Deliver( junk, GetSink( junk )) (large value)
			LeaveLocationTo sink
			Exchange junk to sink for money
		

--]]

local Scavenge = class( "Verb.Scavenge", Verb )

function Scavenge:GetShortDesc( viewer )
	return self.verb:GetShortDesc( viewer )
end

function Scavenge:Interact( actor )
	if math.random() < 0.35 then
		self.verb = Verb.Scrounge( actor )
	elseif math.random() < 0.5 then
		self.verb = Verb.Idle( actor )
	else
		self.verb = Verb.LeaveLocation( actor )
	end
	self.verb:Interact( actor )
end

---------------------------------------------------------------------

local Scavenger = class( "Agenda.Scavenger", Aspect.Agenda )

function Scavenger:init()
	Aspect.Agenda.init( self )
	self:RegisterHandler( AGENT_EVENT.CALC_AGENDA, self.OnCalculateAgenda, self )
end

function Scavenger:OnCalculateAgenda( event_name, agent, agenda )
	assert( agenda == self )
	if self.scavenge == nil then
		self.scavenge = Verb.Scavenge( agent )
	end
	agenda:ScheduleTaskForAgenda( self.scavenge, 7, 12, self )
end

---------------------------------------------------------------------

local Scavenge = class( "Behaviour.Scavenge", Aspect.Behaviour )

function Scavenge:init()
	Scavenge._base.init( self )

	self.scrounge = self:AddVerb( Verb.Scrounge())
end

function Scavenge:CalculatePriority( world )
	-- How broke am I?
	local value = self.owner:GetInventory():CalculateValue()
	if value <= WEALTH.DESTITUTE then
		return PRIORITY.OBLIGATION
	else
		return 1
	end
end

function Scavenge:RunBehaviour()
	self.owner:DoVerb( self.scrounge )
end

---------------------------------------------------------------------


function Agent.Scavenger()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Here's a guy.", GENDER.MALE )
	-- ch:GainAspect( Agenda.Scavenger() )
	ch:GainAspect( Aspect.Behaviour() ):AddBehaviours{
		Behaviour.ManageFatigue(),
		Behaviour.Scavenge()
	}
	ch:GainAspect( Skill.Scrounge() )
	ch:GainAspect( Skill.RumourMonger() ):GainInfo( INFO.LOCAL_NEWS, 3 )
	ch:GainAspect( Interaction.Acquaint( CR1 ) )
	ch:GainAspect( Interaction.Chat() )

	return ch
end