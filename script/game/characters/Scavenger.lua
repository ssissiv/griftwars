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
---------------------------------------------------------------------

local Scavenge = class( "Verb.Scavenge", Verb )

Scavenge.ACT_RATE = 8.0

function Scavenge:init( actor )
	Scavenge._base.init( self, actor )

	self.scrounge = self:AddChildVerb( Verb.Scrounge( actor ) )
	self.idle = self:AddChildVerb( Verb.Idle( actor ) )
	self.leave = self:AddChildVerb( Verb.LeaveLocation( actor ) )
end

function Scavenge:RenderAgentDetails( ui, screen, viewer )
	ui.Bullet()
	ui.Text( "Scavenging for valuables" )
end

function Scavenge:CalculateUtility( actor )
	-- How broke am I?
	local value = actor:GetInventory():CalculateValue()
	if value <= WEALTH.DESTITUTE then
		return UTILITY.OBLIGATION
	else
		return 1
	end
end

function Scavenge:CollectVerbs( verbs, actor, obj )
	if self and self:IsDoing() and obj == self.actor and actor:IsFriends( self.actor ) and actor:GetLocation() == self.actor:GetLocation() then
		assert( is_instance( actor, Agent ), tostring(actor) )
		verbs:AddVerb( Verb.Help( actor, self ))
	end
end

function Scavenge:Interact( actor )
	while not self.cancelled do
		if math.random() < 0.4 then
			self.scrounge:DoVerb( actor )
		elseif math.random() < 0.5 then
			self.idle:DoVerb( actor )
		else
			self.leave:DoVerb( actor )
		end
	end
	Msg:Speak( actor, "Well, that's enough scavenging for now." )
end

---------------------------------------------------------------------

local Scavenger = class( "Agent.Scavenger", Agent )

Scavenger.MAP_CHAR = "s"

function Scavenger:init()
	Agent.init( self )

	self:MakeHuman()

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))
	self:GainAspect( Verb.Scavenge( self ))
end

function Scavenger:GetTitle()
	return "Scavenger"
end


function Scavenger:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Here's a guy.", GENDER.MALE )

	local interactions =
	{
		Interaction.IntroduceAgent( Agent.Shopkeeper ),
		Interaction.RevealObject( Object.JunkHeap, 3 ),
		Interaction.GiftObject( Object.Jerky() ),
	}
	self:GainTrustedInteractions( interactions )
end

function Scavenger:OnLocationEntityEvent( event_name, entity, ... )
	if event_name == AGENT_EVENT.SCROUNGE then
		if entity:IsPlayer() then
			self:DeltaTrust( 5 )
		end
	end
end

