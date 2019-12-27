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

function Scavenge:init( actor )
	Scavenge._base.init( self, actor )

	self.scrounge = self:AddChildVerb( Verb.Scrounge( actor ) )
	self.idle = self:AddChildVerb( Verb.Idle( actor ) )
	self.leave = self:AddChildVerb( Verb.LeaveLocation( actor ) )
end

function Scavenge:GetDetailsDesc( viewer )
	if viewer:CheckPrivacy( self.owner, PRIVACY.INTENT ) then
		return "Scavenging for valuables"
	else
		return "???"
	end
end

function Scavenge:UpdatePriority( actor, priority )
	-- How broke am I?
	local value = actor:GetInventory():CalculateValue()
	if value <= WEALTH.DESTITUTE then
		return PRIORITY.OBLIGATION
	else
		return 1
	end
end

function Scavenge:Interact( actor )
	if math.random() < 0.4 then
		self.scrounge:DoVerb( actor )
	elseif math.random() < 0.5 then
		self.idle:DoVerb( actor )
	else
		self.leave:DoVerb( actor )
	end
end

---------------------------------------------------------------------

local Scavenger = class( "Agent.Scavenger", Agent )

function Scavenger:init()
	Agent.init( self )

	self:GainAspect( Aspect.Behaviour() ):RegisterVerbs{
		Verb.ManageFatigue( self ),
		Verb.Scavenge( self )
	}
	self:GainAspect( Skill.Scrounge() )
	self:GainAspect( Skill.RumourMonger() ):GainInfo( INFO.LOCAL_NEWS, 3 )
	self:GainAspect( Interaction.Acquaint( CR1 ) )
	self:GainAspect( Interaction.Chat() )
end

function Scavenger:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Here's a guy.", GENDER.MALE )
end

