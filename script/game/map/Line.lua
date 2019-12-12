local Line = class( "WorldGen.Line" )

function Line:init( len, dx, dy )
	self.rooms = {}

	if dx == nil and dy == nil then
		dx, dy = 1, 0
	end

	for i = 1, len do
		local room = Location()
		self.rooms[i] = room
		room:SetCoordinate( dx * i, dy * i )
		if i > 1 then
			room:Connect( self.rooms[ i - 1 ] )
		end
	end
end

function Line:Offset( dx, dy, dz )
	for i, room in ipairs( self.rooms ) do
		local x, y, z = room:GetCoordinate()
		room:SetCoordinate( x + dx, y + dy, z + dz )
	end
end

function Line:SetDetails( title, desc )
	for i, room in ipairs( self.rooms ) do
		room:SetDetails( loc.format( "{1} [{2}]", title, i ), desc )
	end
end

function Line:SetImage( path )
	for i, room in ipairs( self.rooms ) do
		room:SetImage( path )
	end
end

function Line:RoomCount()
	return #self.rooms
end

function Line:RoomAt( i )
	return self.rooms[ i ]
end

function Line:Rooms()
	return ipairs( self.rooms )
end

