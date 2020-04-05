local Mountains = class( "WorldGen.Mountains", Zone )

function Mountains:init( worldgen, origin, size )
	Zone.init( self, worldgen )

	self.origin = origin
	self.size = size
end

function Mountains:GenerateZone()
	local function CreateRoom( room )
		room:SetDetails( loc.format( "Mountains [{1}]", #self.rooms ), "High altitude, treacherous terrain.")
		room:SetImage( assets.LOCATION_BGS.MOUNTAINS )
		room.map_colour = constants.colours.MOUNTAINS_TILE

		table.insert( self.rooms, room )
	end

	self.worldgen:SproutLocations( self.origin, self.size, CreateRoom )
end


