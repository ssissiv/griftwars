local Dirk = class( "Weapon.Dirk", Object )

Dirk.EQ_SLOT = EQ_SLOT.HAND

function Dirk:GetName()
	return "Dirk"
end

function Dirk:GetValue()
	return 12
end
