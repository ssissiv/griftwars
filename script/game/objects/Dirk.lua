local Dirk = class( "Weapon.Dirk", Object )

function Dirk:init()
	Object.init( self )
	self.value = 12

	self:GainAspect( Aspect.Wearable( EQ_SLOT.HAND ))
end

function Dirk:GetName()
	return "dirk"
end
