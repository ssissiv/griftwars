local assets =
{
	FONTS =
	{
	},

	OPINION_IMG =
	{
		FEAR = "fear.png",
		LIKE = "liked.png",
		DISLIKE = "unliked.png",
	},

	LOCATION_BGS =
	{
		HOME = "home.png",
		JUNKYARD_STRIP = "junkyard_strip.png",
	},

	LoadAll = function( self )
		for k, filename in pairs( self.OPINION_IMG ) do
			self.OPINION_IMG[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end

		for k, filename in pairs( self.LOCATION_BGS ) do
			self.LOCATION_BGS[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end
	end
}


return assets