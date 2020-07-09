local Weapon = class( "Object.Weapon", Object )

function Weapon:init()
	Object.init( self )

	self:GainAspect( Aspect.Wearable( EQ_SLOT.WEAPON ))
	self:GainAspect( Aspect.Carryable() )
end
