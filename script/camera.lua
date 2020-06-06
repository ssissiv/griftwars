local Camera = class( "Camera" )

function Camera:init()
	self.x = 0
	self.y = 0
	self.targetx = 0
	self.targety = 0
	self.zoom = 1.0
end

function Camera:GetPosition()
	return self.x, self.y
end

function Camera:UpdateCamera( dt )
	self.x = (self.x + self.targetx) * 0.5
	self.y = (self.y + self.targety) * 0.5
end

function Camera:GetZoom()
	return self.zoom
end

function Camera:ZoomTo( zoom )
	assert( zoom > 0 )
	self.zoom = zoom
end

function Camera:ZoomToLevel( level, x, y )
	local x0, y0
	if x and y then
		x0, y0 = self:ScreenToWorld( x, y )
	end

	-- translate level level to zoom.  Level 0 means DEFAULT_ZOOM, >0 means greater zoom, <0 means less zoom.
	if level == 0 then
		self:ZoomTo( DEFAULT_ZOOM )
	elseif level > 0 then
		self:ZoomTo( DEFAULT_ZOOM * (level + 1) )
	elseif level < 0 then
		self:ZoomTo( DEFAULT_ZOOM / math.abs(level - 1) )
	end

	if x and y then
		-- zoom to this point
		local x1, y1 = self:ScreenToWorld( x, y )
		self:Offset( x0 - x1, y0 - y1 )
	end
end

function Camera:WarpTo( x, y )
	self.x, self.y = x, y
	self.targetx, self.targety = self.x, self.y
end

function Camera:Offset( dx, dy )
	self.x = self.x + dx
	self.y = self.y + dy
	self.targetx, self.targety = self.x, self.y
end

function Camera:PanTo( x, y )
	self.targetx = x
	self.targety = y
end

function Camera:Pan( dx, dy )
	self.targetx = self.targetx + dx
	self.targety = self.targety + dy
end

function Camera:ScreenToWorld( mx, my )
	local x = (mx - self.view_x) * self.zoom + self.x
	local y = (my - self.view_y) * self.zoom + self.y
	return x, y
end

function Camera:WorldToScreen( x, y )
	local mx = (x - self.x) / self.zoom + self.view_x
	local my = (y - self.y) / self.zoom + self.view_y
	return mx, my
end

function Camera:SetViewPort( x, y, w, h )
	self.view_x, self.view_y = x, y
	self.view_width, self.view_height = w, h
end

function Camera:RenderDebug()
	imgui.Text( string.format( "Camera: %.2f, %.2f; Zoom: %.2f", self.x, self.y, self.zoom ))
end
