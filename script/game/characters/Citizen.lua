---------------------------------------------------------------------
-- A "normal" citizen.

local Citizen = class( "Agent.Citizen", Agent )
Citizen.MAP_CHAR = "c"

function Citizen:init()
	Agent.init( self )

	self:MakeHuman()

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))

	self:GainAspect( Interaction.Befriend( CR1 ) )
	self:GainAspect( Interaction.Chat() )
end
