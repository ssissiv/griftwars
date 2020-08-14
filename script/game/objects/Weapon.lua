local Weapon = class( "Object.Weapon", Object )
Weapon.mass = 1

function Weapon:init()
	Object.init( self )

	self:GainAspect( Aspect.Wearable( EQ_SLOT.WEAPON ))
	self:GainAspect( Aspect.Carryable() )
end

function Weapon:GetAttackRange()
	return self.attack_range or 1.5
end
