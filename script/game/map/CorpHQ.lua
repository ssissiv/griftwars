local CorpHQ = class( "WorldGen.CorpHQ" )

function CorpHQ:init()
	self.rooms = {}

	local hall = WorldGen.Line( 8 )
	hall:SetDetails( "Office Hallway", "A generic hallway.")
	hall:SetImage( assets.LOCATION_BGS.HALLWAY )
	self.hall = hall

	local entrance = Location()
	entrance:SetDetails( "Entrance Foyer", "A foyer to an office building.")
	entrance:Connect( hall:RoomAt( 1 ))
	self.entrance = entrance
	table.insert( self.rooms, entrance )

	local office = Location()
	office:SetDetails( "Office", "An office where business happens.")
	hall:RoomAt( 2, hall:RoomCount() ):Connect( office )
	self.office = office

	table.arrayadd( self.rooms, hall.rooms )
end

function CorpHQ:SetCorpName( name )
	self.entrance:SetDetails( loc.format( "Entrance Foyer for {1}", name ))
	for i, room in self.hall:Rooms() do
		room:SetDetails( loc.format( "{1} Hallway", name ))
	end
end

function CorpHQ:GetEntrance()
	return self.entrance
end

function CorpHQ:GetOffice()
	return self.office
end

function CorpHQ:RandomRoom()
	return table.arraypick( self.rooms )
end

function CorpHQ:RoomAt( i )
	return self.rooms[ i ]
end
