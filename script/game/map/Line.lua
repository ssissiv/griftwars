local Line = class( "WorldGen.Line" )

function Line:init( len )
	self.rooms = {}

	for i = 1, len do
		local room = Location()
		self.rooms[i] = room
		room:SetCoordinate( i )
		if i > 1 then
			room:Connect( self.rooms[ i - 1 ] )
		end
	end
end

function Line:SetDetails( title, desc )
	for i, room in ipairs( self.rooms ) do
		room:SetDetails( loc.format( "{1} [{2}]", title, i ), desc )
	end
end

function Line:RoomAt( i )
	return self.rooms[ i ]
end
