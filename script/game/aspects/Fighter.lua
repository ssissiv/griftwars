
---------------------------------------------------------------------

local Fighter = class( "Agent.Fighter", Agent )

function Fighter:init()
	Agent.init( self )
	
	self.species = SPECIES.HUMAN
	
	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Aspect.Combat() )
	self:GainAspect( Skill.Fighter() )
end

function Fighter:GetTitle()
	return "Fighter"
end