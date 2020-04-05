local Forest = class( "WorldGen.Forest", Zone )

function Forest:init( worldgen, origin, size )
	Zone.init( self, worldgen )

	self.origin = origin
	self.size = size
end

function Forest:GenerateZone()
	local function CreateRoom( room )
		room:SetDetails( loc.format( "The Forest [{1}]", #self.rooms ), "A generic forest, this area abounds with trees, shrubs, and wildlife.")
		room:SetImage( assets.LOCATION_BGS.FOREST )
		if self.worldgen:Random() < 0.5 then
			room:GainAspect( Aspect.ScroungeTarget( QUALITY.POOR ) )
		end
		room.map_colour = constants.colours.FOREST_TILE

		table.insert( self.rooms, room )
	end

	self.worldgen:SproutLocations( self.origin, self.size, CreateRoom )

	-- self:PopulateOrcs()
end

function Forest:PopulateOrcs()
	local n = self.worldgen:Random( 3 )
	if n == 1 then
		-- Some Orcs
		n = math.ceil( #self.rooms / 5 )
	elseif n == 2 then
		-- LOTS of Orcs!
		n = math.ceil( #self.rooms / 3 )
	else
		-- No orcs!
		n = 0
	end
	for i = 1, n do
		local orc = Agent.Orc()
		orc:WarpToLocation( self:RandomRoom() )
	end
end

function Forest:RandomRoom()
	return self.worldgen:ArrayPick( self.rooms )
end

function Forest:GetRooms()
	return self.rooms
end

function Forest:RoomAt( i )
	return self.rooms[ i ]
end
