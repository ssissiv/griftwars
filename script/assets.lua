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

	LoadAll = function( self )
		for k, filename in pairs( self.OPINION_IMG ) do
			self.OPINION_IMG[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end
	end
}


return assets