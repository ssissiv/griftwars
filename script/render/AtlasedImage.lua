local AtlasedImage = class( "AtlasedImage" )

function AtlasedImage:init( image, x, y, w, h )
	self.image = image
	self.w, self.h = w, h
	self.quad = love.graphics.newQuad(x, y, w, h, image:getDimensions())
end

function AtlasedImage:RenderImage( x, y, w, h )
	local sx, sy = (w or self.w) / self.w, (h or self.h) / self.h
	love.graphics.draw( self.image, self.quad, x, y, 0, sx, sy )
end

