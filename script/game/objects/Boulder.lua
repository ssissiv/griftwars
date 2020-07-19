local Boulder = class( "Object.Boulder", Object )
Boulder.MAP_CHAR = "B"
Boulder.image = assets.TILE_IMG.BOULDER
Boulder.mass = 12
Boulder.range_attack_power = 10

function Boulder:GetName()
	return "Boulder"
end

function Boulder:init()
	Object.init( self )

	self:GainAspect( Aspect.Carryable() )
end