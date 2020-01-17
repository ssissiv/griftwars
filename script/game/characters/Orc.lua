
---------------------------------------------------------------------

local Orc = class( "Agent.Orc", Agent )

function Orc:init()
	Agent.init( self )
	self.species = SPECIES.ORC

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))
end

function Orc:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A pretty feral beast.", GENDER.MALE )
end

