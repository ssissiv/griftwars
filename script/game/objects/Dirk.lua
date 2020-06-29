local Dirk = class( "Weapon.Dirk", Object )

Dirk.image = assets.IMG.DIRK
Dirk.attack_power = 3

function Dirk:init()
	Object.init( self )
	self.value = 12

	self:GainAspect( Aspect.Wearable( EQ_SLOT.WEAPON ))
	self:GainAspect( Aspect.Carryable() )
end

function Dirk:GetName()
	return "dirk"
end

------------------------------------------------------------------

local JaggedDirk = class( "Weapon.JaggedDirk", Object )

Dirk.image = assets.IMG.DIRK
Dirk.attack_power = 4

function JaggedDirk:init()
	Object.init( self )
	self.value = 35

	self:GainAspect( Aspect.Wearable( EQ_SLOT.WEAPON ))
	self:GainAspect( Aspect.Carryable() )
end

function JaggedDirk:GetName()
	return "jagged dirk"
end
