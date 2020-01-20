local assets =
{
	FONTS =
	{
		TITLE = "Ayuthaya.ttf",
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

	LoadAll = function( self )
		for k, filename in pairs( self.FONTS ) do
			self.FONTS[ k ] = love.graphics.newFont( string.format( "data/%s", filename ), 16 )
		end
		 
		for k, filename in pairs( self.AFFINITY_IMG ) do
			self.AFFINITY_IMG[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end

		for k, filename in pairs( self.LOCATION_BGS ) do
			self.LOCATION_BGS[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end
	end
}


return assets