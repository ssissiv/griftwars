
---------------------------------------------------------------------

local Orc = class( "Agent.Orc", Agent )

function Orc:init()
	Agent.init( self )

	Agent.MakeOrc( self )

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))
	self:GainAspect( Aspect.Combat() )
end

function Orc:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A pretty feral beast.", GENDER.MALE )
end

