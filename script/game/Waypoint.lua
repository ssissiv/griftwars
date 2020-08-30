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

function Waypoint:SetTag( tag )
	self.tag = tag
	return self
end

function Waypoint:TrackEntity( ent )
	self.entity = ent
end

function Waypoint:OccupyWaypoint( occupant )
	assert( occupant )
	self.occupant = occupant
end

function Waypoint:UnoccupyWaypoint( occupant )
	assert( occupant == self.occupant )
	self.occupant = nil
end

function Waypoint:IsOccupied()
	return self.occupant ~= nil
end

function Waypoint:GetOccupied()
	return self.occupant
end

function Waypoint:MatchTag( tag )
	return self.tag == tag
end

function Waypoint:Match( location, tx, ty )
	local location, x, y = self:GetLocation(), self:GetCoordinate()
	return location == self:GetLocation() and x == tx and y == ty
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
	local dest, destx, desty = self:GetDest()
	return dest == location and (destx == nil or destx == x) and (desty == nil or desty == y)
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
