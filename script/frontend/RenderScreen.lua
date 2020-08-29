local RenderScreen = class( "RenderScreen" )

function RenderScreen:init()
	self.render_bounds = {}
end

function RenderScreen:IsOpaque()
	return self.opaque == true
end

function RenderScreen:GetScreenSize()
	return love.graphics.getWidth(), love.graphics.getHeight()
end

function RenderScreen:DebugText( x, y, txt, clr )
	if clr then
		self:SetColour( clr )
	end
	love.graphics.setFont( assets.FONTS.TITLE )
	love.graphics.print( txt, x, y )
end

function RenderScreen:Rectangle( x, y, w, h )
	love.graphics.rectangle( "fill", x, y, w, h )
	self.render_bounds[1] = x
	self.render_bounds[2] = y
	self.render_bounds[3] = w
	self.render_bounds[4] = h
end

function RenderScreen:Box( x, y, w, h )
	love.graphics.rectangle( "line", x, y, w, h )
	self.render_bounds[1] = x
	self.render_bounds[2] = y
	self.render_bounds[3] = w
	self.render_bounds[4] = h
end

function RenderScreen:SetColour( clr )
	local r, g, b, a
	if type(clr) == "table" then
		r, g, b, a = table.unpack( clr )
	else
		r, g, b, a = HexColour255( clr )
	end
	love.graphics.setColor( r, g, b, a )
end

function RenderScreen:Image( image, x, y, w, h )
	if is_instance( image, AtlasedImage ) then
		image:RenderImage( x, y, w, h )
	else
		local sx, sy = w / image:getWidth(), h / image:getHeight()
		love.graphics.draw( image, x, y, 0, sx, sy )
	end
end

function RenderScreen:IsHovered()
	local mx, my = love.mouse.getPosition()
	local x, y, w, h = table.unpack( self.render_bounds )
	if x and y and mx >= x and my >= y and mx <= x + w and my <= y + h then
		return true
	end

	return false
end

function RenderScreen:SetTooltip( txt )
	self.tooltip = txt
	self.tooltip_bounds = table.shallowcopy( self.render_bounds )
end

function RenderScreen:RenderTooltip( ui )
	if not self.tooltip then
		return
	end

    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove" }
    local x, y, w, h = table.unpack( self.tooltip_bounds )
	ui.SetNextWindowPos( x + w, y + h )

    ui.Begin( "TOOLTIP", true, flags )
    	ui.Text( self.tooltip )
    ui.End()
end

function RenderScreen:__tostring()
	return string.format( "[%s]", self._classname )
end
