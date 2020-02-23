
---------------------------------------------------------------------

local Fighter = class( "Agent.Fighter", Agent )

function Fighter:init()
	Agent.init( self )
	
	self.species = SPECIES.HUMAN
	
	self:GainAspect( Aspect.Behaviour() )
end

function Fighter:GetTitle()
	return "Fighter"
end