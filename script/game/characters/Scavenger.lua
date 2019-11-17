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

local Scavenge = class( "Behaviour.Scavenge", Aspect.Behaviour )

function Scavenge:init()
	Scavenge._base.init( self )

	self.scrounge = self:AddVerb( Verb.Scrounge())
	self.idle = self:AddVerb( Verb.Idle())
	self.leave = self:AddVerb( Verb.LeaveLocation())
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
	assert( not self:IsRunning() )
	if math.random() < 0.35 then
		self.owner:DoVerb( self.scrounge )
	elseif math.random() < 0.5 then
		self.owner:DoVerb( self.idle )
	else
		self.owner:DoVerb( self.leave )
	end
end

---------------------------------------------------------------------


function Agent.Scavenger()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Here's a guy.", GENDER.MALE )
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