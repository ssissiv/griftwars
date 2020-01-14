---------------------------------------------------------------------
-- A "normal" citizen.

local Citizen = class( "Agent.Citizen", Agent )

function Citizen:init()
	Agent.init( self )

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))

	self:GainAspect( Interaction.Acquaint( CR1 ) )
	self:GainAspect( Interaction.Chat() )
end
