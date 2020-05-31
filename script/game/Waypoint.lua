local Waypoint = class( "Waypoint" )

function Waypoint:init( a, b, c )
	if is_instance( a, Location ) then
		assert( b == nil or type(b) == "number" )
		assert( c == nil or type(c) == "number" )
		self.location, self.x, self.y = a, b, c

	elseif is_instance( a, Entity ) then
		self.entity = a
	end
end

function Waypoint:TrackLocation( location, x, y )
	self.location, self.x, self.y = location, x, y
end

function Waypoint:TrackEntity( ent )
	self.entity = ent
end

function Waypoint:GetCoordinate()
	if self.entity then
		return self.entity:GetCoordinate()
	else
		return self.x, self.y
	end
end

function Waypoint:GetDest()
	local location, x, y = self:GetLocation(), self:GetCoordinate()
	return location, x, y
end

function Waypoint:GetLocation()
	if self.entity then
		return self.entity:GetLocation()
	else
		return self.location
	end
end

function Waypoint:AtWaypoint( entity )
	local location, x, y = entity:GetLocation(), entity:GetCoordinate()
	return self.location == location and (self.x == nil or self.x == x) and (self.y == nil or self.y == y)
end

function Waypoint:__tostring()
	assert( self._class == Waypoint )
	local location, x, y = self:GetLocation(), self:GetCoordinate()
	if location and x and y then
		return string.format( "Waypoint<%s:%d,%d>", location, x, y )
	elseif location then
		return string.format( "Waypoint<%s>", location )
	else
		return "Waypoint<>"
	end
end
