local Hills = class( "WorldGen.Hills", Zone )

function Hills:init( worldgen, origin, size )
	Zone.init( self, worldgen )

	self.origin = origin
	self.size = size
end

function Hills:GenerateZone()
	local function CreateRoom( room )
		room:SetDetails( loc.format( "Hills [{1}]", #self.rooms ), "Hilly, untamed terrain. Progress is inconsistent.")
		room:SetImage( assets.LOCATION_BGS.HILLS )
		room.map_colour = constants.colours.HILLS_TILE

		table.insert( self.rooms, room )
	end

	self.worldgen:SproutLocations( self.origin, self.size, CreateRoom )
end


