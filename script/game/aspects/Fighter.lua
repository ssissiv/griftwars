
---------------------------------------------------------------------

local Fighter = class( "Agent.Fighter", Agent )

Fighter.MAP_CHAR = "f"

function Fighter:init()
	Agent.init( self )
	
	self:MakeHuman()

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Skill.Fighter() )
end

function Fighter:GetTitle()
	return "Fighter"
end