local Floater = class( "Floater" )

function Floater:init( txt )
	self.txt = txt
	self.duration = 1.5
	self.dt = 0
end

function Floater:SetCoordinate( x, y )
	self.x, self.y = x, y
	return self
end

function Floater:SetColour( colour )
	self.colour = colour
	return self
end

function Floater:UpdateFloater( dt )
	self.dt = self.dt + dt
	return self.dt < self.duration
end

function Floater:RenderFloater( screen )
	local x, y = screen.camera:WorldToScreen( self.x, self.y )
	y = y - Easing.outExpo( self.dt, 0, 20, self.duration )

	local a = 1.0 - math.max( 0, self.dt - self.duration * 0.8) / (self.duration * 0.2)
	love.graphics.setFont( assets.FONTS.FLOATER )

	-- Black background
	screen:SetColour( AlphaColour( 0x000000FF, a ))
	love.graphics.print( self.txt, x + 1, y + 2 )

	-- Foreground
	local clr = AlphaColour( self.colour or 0xFFFFFFFF, a )
	screen:SetColour( clr )

	love.graphics.print( self.txt, x, y )
end
