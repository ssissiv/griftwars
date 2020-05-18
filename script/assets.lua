local assets =
{
	FONTS =
	{
		TITLE = { "Ayuthaya.ttf", 16 },
		SUBTITLE = { "Ayuthaya.ttf", 12 },
		MAP_TILE = { "Ayuthaya.ttf", 48 }
	},

	AFFINITY_IMG =
	{
		--FEAR = "fear.png",
		KNOWN = "known.png",
		FRIEND = "liked.png",
		UNFRIEND = "unliked.png",
		ENEMY = "unliked.png",
	},

	LOCATION_BGS =
	{
		HOME = "home.png",
		INSIDE = "inside.png",
		SHOP = "shop.png",
		JUNKYARD_STRIP = "junkyard_strip.png",
		HALLWAY = "inside.png",
		FOREST = "forest.png",
	},

	TILE_IMG =
	{
		GRASS = "grassland.png",
		TREE = "tree.png",
		STONE_FLOOR = "stone_floor.png",
		STONE_WALL = "stone_wall.png",
		WOODEN_FLOOR = "wooden_floor.png",
		DIRT_FLOOR = "dirt_floor.png",

		DOOR = "door.png",
		BED = "bed.png",
		CAVE_ENTRANCE = "cave_entrance.png",
		CHEST = "chest.png",
		ABANDONED_WELL = "abandoned_well.png",

	},

	LoadAll = function( self )
		for k, t in pairs( self.FONTS ) do
			self.FONTS[ k ] = love.graphics.newFont( string.format( "data/%s", t[1] ), t[2] )
		end
		 
		for k, filename in pairs( self.AFFINITY_IMG ) do
			self.AFFINITY_IMG[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end

		for k, filename in pairs( self.LOCATION_BGS ) do
			self.LOCATION_BGS[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end

		for k, filename in pairs( self.TILE_IMG ) do
			self.TILE_IMG[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end
	end
}


return assets