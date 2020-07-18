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

local Scavenge = class( "Verb.Scavenge", Verb.Plan )

function Scavenge:init()
	Scavenge._base.init( self )

	self.scrounge = Verb.Scrounge()
	self.wander = Verb.Wander()
end

function Scavenge:GetDesc( viewer )
	return "Scavenging for valuables"
end

function Scavenge:CalculateUtility( actor )
	-- How broke am I?
	local value = actor:GetInventory():CalculateValue()
	if value <= WEALTH.DESTITUTE then
		return UTILITY.DUTY
	else
		return 1
	end
end

-- function Scavenge:CollectVerbs( verbs, actor, obj )
-- 	if  and obj == self.actor and actor:IsFriends( self.actor ) and actor:GetLocation() == self.actor:GetLocation() then
-- 		assert( is_instance( actor, Agent ), tostring(actor) )
-- 		verbs:AddVerb( Verb.Help( actor, self ))
-- 	end
-- end

function Scavenge:Interact( actor )
	local i = 0
	while not self.cancelled do
		if math.random() < 0.4 then
			self:DoChildVerb( self.scrounge )
		elseif math.random() < 0.5 then
			self:DoChildVerb( self.wander, nil, 10 * ONE_MINUTE )
		end
		i = i + 1
		assert( i < 10000, " bad scavenge ")
	end
	Msg:Speak( actor, "Well, that's enough scavenging for now." )
end

---------------------------------------------------------------------

local Scavenger = class( "Agent.Scavenger", Agent )

Scavenger.MAP_CHAR = "s"
Scavenger.unfamiliar_desc = "scavenger"

function Scavenger:init()
	Agent.init( self )

	self:MakeHuman()

	self:GainAspect( Verb.Scavenge( self ))
end

function Scavenger:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Here's a guy.", GENDER.MALE )

	-- local interactions =
	-- {
	-- 	Interaction.IntroduceAgent( Agent.Shopkeeper ),
	-- 	Interaction.RevealObject( Object.JunkHeap, 3 ),
	-- 	Interaction.GiftObject( Object.Jerky() ),
	-- }
	-- self:GainTrustedInteractions( interactions )
	Aspect.Favour.GainFavours( self,
	{
		{ Favour.Acquaint(), 10 },
		{ Favour.GainXP( 100 ), 20 },
		{ Favour.Gift( LOOT_GIFT_SCAVENGER ), 30 },
		{ Favour.BoostTrustWithClass( 20 ), 40 },
		{ Favour.LearnIntel(), 15 },
	})
end

function Scavenger:OnLocationEntityEvent( event_name, entity, ... )
	if event_name == AGENT_EVENT.SCROUNGE then
		if entity:IsPlayer() then
			self:DeltaTrust( 5 )
		end
	end
end

function Scavenger:GetRelationshipAffinities()
	if self.RELATIONSHIP_AFFINITIES == nil then
		self.RELATIONSHIP_AFFINITIES =
		{
			AgentClassGenerator( Agent.Scavenger ), 5,
			AgentClassGenerator( Agent.Snoop ), 2,
			AgentClassGenerator( Agent.Citizen ), 1,
			AgentClassGenerator( Agent.CityGuard ), 1,
		}
	end

	return self.RELATIONSHIP_AFFINITIES
end


