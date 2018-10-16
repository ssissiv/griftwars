local assets =
{
	FONTS =
	{
	},

	IMGS =
	{
		liked = "liked.png",
		disliked = "unliked.png",
	},

	LoadAll = function( self )
		for k, filename in pairs( self.IMGS ) do
			self.IMGS[ k ] = love.graphics.newImage( string.format( "data/%s", filename ))
		end
	end
}


return assets