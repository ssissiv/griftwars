local Object = class( "Object", Entity )

function Object:init()
	Entity.init( self )
	self.value = 0
end

function Object:GetValue()
	return 0
end

function Object:DeltaValue( delta )
	self.value = math.max( self.value + delta, 0 )
end

function Object:GetLocation()
	return self.location
end
