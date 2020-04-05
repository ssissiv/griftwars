local Line = class( "WorldGen.Line" )

function Line:init( len, exit )
	self.rooms = {}

	for i = 1, len do
		local room = Location()
		self.rooms[i] = room
		if i > 1 then
			self.rooms[ i - 1 ]:Connect( room, exit )
		end
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

function Line:RandomRoom()
	return table.arraypick( self.rooms )
end

function Line:RoomAt( i )
	return self.rooms[ i ]
end

function Line:Rooms()
	return ipairs( self.rooms )
end

