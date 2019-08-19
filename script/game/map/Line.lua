local Line = class( "WorldMap.Line" )

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

function Line:RoomAt( i )
	return self.rooms[ i ]
end

function Line:MergeAt( i, room )
	return self.rooms[ i ]:Merge( room )
end

function Line:Begin()
	return self.rooms[ 1 ]
end

function Line:End()
	return self.rooms[ #self.rooms ]
end
