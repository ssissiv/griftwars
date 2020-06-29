local AtlasedImage = class( "AtlasedImage" )

function AtlasedImage:init( image, x, y, w, h )
	self.image = image
	self.w, self.h = w, h
	self.x, self.y = x, y
	self.quad = love.graphics.newQuad(x, y, w, h, image:getDimensions())
end

function AtlasedImage:RenderImage( x, y, w, h )
	local sx, sy = (w or self.w) / self.w, (h or self.h) / self.h
	love.graphics.draw( self.image, self.quad, x, y, 0, sx, sy )
end

function AtlasedImage:RenderUI( ui, x, y, w, h )
	local W, H = self.image:getWidth(), self.image:getHeight()
	local uvx1, uvy1 = self.x / W, self.y / H
	local uvx2, uvy2 = (self.x + self.w) / W, (self.y + self.h) / H
	ui.Image( self.image, 48, 48, uvx1, uvy1, uvx2, uvy2 )
end
