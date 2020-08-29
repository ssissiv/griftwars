require "game/aspects/statvalue"

local Resource = class( "Aspect.Resource", Aspect.StatValue )

function Resource:init( stat, value )
	assert( IsEnum( stat, RESOURCE ))
	Resource._base.init( self, stat, value, 99, 0 )
end

function Resource:SetTargetValue( target )
	self.target_value = target
end

function Resource:GetTargetValue()
	return self.target_value
end
