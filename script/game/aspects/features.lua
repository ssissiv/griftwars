local Feature = class( "Feature", Aspect )

function Feature:init()
end

function Feature:OnGainAspect( obj )
	assert( is_instance( obj, Location ))
	self.location = obj
	Aspect.OnGainAspect( self, obj )
end
