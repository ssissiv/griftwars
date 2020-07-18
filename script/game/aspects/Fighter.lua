
---------------------------------------------------------------------

local Fighter = class( "Agent.Fighter", Agent )

Fighter.MAP_CHAR = "f"
Fighter.unfamiliar_desc = "fighter"

function Fighter:init()
	Agent.init( self )
	
	self:MakeHuman()

	self:GainAspect( Skill.Fighting() )
end
