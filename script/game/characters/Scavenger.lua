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
	if math.random() < 0.5 then
		self.verb = Verb.Scrounge( actor )
	else
		self.verb = Verb.LeaveLocation( actor )
	end
	self.verb:Interact( actor )
end

local Scavenger = class( "Agenda.Scavenger", Aspect.Agenda )

function Scavenger:init()
	Aspect.Agenda.init( self )
	self:RegisterHandler( AGENT_EVENT.CALC_AGENDA, self.OnCalculateAgenda )
end

function Scavenger:OnCalculateAgenda( event_name, agent, agenda )
	agenda:ScheduleTaskForAgenda( Verb.Scavenge( agent ), 7, 12 )
end

---------------------------------------------------------------------


function Agent.Scavenger()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Here's a guy.", GENDER.MALE )
	ch:GainAspect( Agenda.Scavenger() )
	-- ch:GainAspect( Skill.Scrounge() )
	ch:GainAspect( Skill.RumourMonger() ):GainInfo( INFO.LOCAL_NEWS, 3 )
	ch:GainAspect( Interaction.Acquaint() )
	ch:GainAspect( Interaction.Chat() )

	return ch
end