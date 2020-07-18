
---------------------------------------------------------------------

local HillGiant = class( "Agent.HillGiant", Agent )
HillGiant.unfamiliar_desc = "hill giant"
HillGiant.image = assets.TILE_IMG.HILL_GIANT

HillGiant.max_health = 82
HillGiant.strength = 14

function HillGiant:init()
	Agent.init( self )

	Agent.MakeHillGiant( self )

	self:SetFlags( EF.AGGRO_ALL )
end

function HillGiant:GetMapChar()
	return "H", constants.colours.YELLOW
end
