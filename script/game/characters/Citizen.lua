---------------------------------------------------------------------
-- A "normal" citizen.

local Citizen = class( "Agent.Citizen", Agent )
Citizen.MAP_CHAR = "c"
Citizen.unfamiliar_desc = "citizen"

function Citizen:init()
	Agent.init( self )

	self:MakeHuman()
end
