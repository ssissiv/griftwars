local RoadLocation = class( "Location.Road", Location )

function RoadLocation:init( zone )
	Location.init( self )
	self:SetDetails( loc.format( "City of {1}", zone.name), "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	self:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
end

