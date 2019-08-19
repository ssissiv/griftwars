local Feature = class( "Feature", Aspect )

function Feature:OnGainAspect( obj )
	assert( is_instance( obj, Location ))
	self.location = obj
end

---------------------------------------------------------------

local Portal = class( "Feature.Portal", Feature )

function Portal:init( dest_location, tag )
	assert( is_instance( dest_location, Location ))
	self.dest_location = dest_location
end

---------------------------------------------------------------
