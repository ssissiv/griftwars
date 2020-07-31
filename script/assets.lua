local assets =
{
	FONTS =
	{
		TITLE = { "Ayuthaya.ttf", 16 },
		SUBTITLE = { "Ayuthaya.ttf", 12 },
		MAP_TILE = { "Ayuthaya.ttf", 48 },
		FLOATER = { "Arial Black.ttf", 26 },
	},

	AFFINITY_IMG =
	{
		--FEAR = "fear.png",
		KNOWN = "known.png",
		FRIEND = "liked.png",
		UNFRIEND = "unliked.png",
		ENEMY = "unliked.png",
	},

	IMG =
	{
		ZZZ = "sleeping.png",
		UNKNOWN_LOCATION = "unknown_location.png",

		-- Objects
		DIRK = { "NEVANDA", 15 * 32, 10 * 32, 32, 32 },
		LONG_SWORD = { "NEVANDA", 23 * 32, 10 * 32, 32, 32 },
		CHAIN_MAIL = { "NEVANDA", 23 * 32, 12 * 32, 32, 32 },
	},

	ATLASES =
	{
		NEVANDA = "nevanda.png",
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
		DOOR_OPEN = "door_open.png",
		BED = "bed.png",
		TENT = "tent.png",
		BOULDER = { "NEVANDA", 0 * 32, 21 * 32, 32, 32 },
		CAVE_ENTRANCE = "cave_entrance.png",
		CHEST = "chest.png",
		ABANDONED_WELL = "abandoned_well.png",

		PLAYER = { "NEVANDA", 4 * 32, 1 * 32, 32, 32 },
		BANDIT = { "NEVANDA", 7 * 32, 1 * 32, 32, 32 },
		BANDIT_CAPTAIN = { "NEVANDA", 5 * 32, 1 * 32, 32, 32 },
		ORC = { "NEVANDA", 32 * 32, 1 * 32, 32, 32 },
		CAPTAIN = { "NEVANDA", 3 * 32, 7 * 32, 32, 32 },
		HILL_GIANT = { "NEVANDA", 16 * 32, 4 * 32, 32, 32 },
	},

	LoadImage = function( self, img )
		if type(img) == "string" then
			local filename = string.format( "data/%s", img )
			return love.graphics.newImage( filename )
		elseif type(img) == "table" then
			local atlas_name, x, y, w, h = table.unpack(img)
			assert( self.ATLASES[ atlas_name ], atlas_name )
			return AtlasedImage( self.ATLASES[ atlas_name ], x, y, w, h )
		else
			error( "invalid img: "..tostring(img) )
		end
	end,

	LoadAll = function( self )
		for k, t in pairs( self.FONTS ) do
			self.FONTS[ k ] = love.graphics.newFont( string.format( "data/%s", t[1] ), t[2] )
		end
		 
		for k, filename in pairs( self.ATLASES ) do
			self.ATLASES[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end

		for k, v in pairs( self.AFFINITY_IMG ) do
			self.AFFINITY_IMG[ k ] = self:LoadImage( v )
		end

		for k, v in pairs( self.IMG ) do
			self.IMG[ k ] = self:LoadImage( v )
		end

		for k, v in pairs( self.TILE_IMG ) do
			self.TILE_IMG[ k ] = self:LoadImage( v )
		end
	end
}


return assets