local Feature = class( "Feature", Aspect )

function Feature:OnGainAspect( obj )
	assert( is_instance( obj, Location ))
	self.location = obj
end
