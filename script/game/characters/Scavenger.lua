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

function Scavenge:init()
	Scavenge._base.init( self )

	self.scrounge = Verb.Scrounge()
	self.idle = Verb.Idle()
	self.leave = Verb.LeaveLocation()
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
	if math.random() < 0.35 then
		self.scrounge:DoVerb( actor )
	elseif math.random() < 0.5 then
		self.idle:DoVerb( actor )
	else
		self.leave:DoVerb( actor )
	end
end

---------------------------------------------------------------------


function Agent.Scavenger()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Here's a guy.", GENDER.MALE )
	ch:GainAspect( Aspect.Behaviour() ):RegisterVerbs{
		Verb.ManageFatigue(),
		Verb.Scavenge()
	}
	ch:GainAspect( Skill.Scrounge() )
	ch:GainAspect( Skill.RumourMonger() ):GainInfo( INFO.LOCAL_NEWS, 3 )
	ch:GainAspect( Interaction.Acquaint( CR1 ) )
	ch:GainAspect( Interaction.Chat() )

	return ch
end