---------------------------------------------------------------------
-- A "normal" citizen.

local Citizen = class( "Agent.Citizen", Agent )
Citizen.MAP_CHAR = "c"
Citizen.unfamiliar_desc = "citizen"

function Citizen:init()
	Agent.init( self )

	self:MakeHuman()

	self:GainAspect( Aspect.Behaviour() )

	self:GainAspect( Interaction.Befriend( CR1 ) )
	self:GainAspect( Interaction.Chat() )
end
