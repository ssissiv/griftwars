---------------------------------------------

local ui = class( "UI" )

function ui:init()
	self.input = { keys_pressed = {}, btns = {}, time_pressed = {} }
	self.screens = {}
	self.log = {}

	self.styles = {}
	self.styles.default = love.graphics.getFont()
	self.styles.header = love.graphics.newFont( "data/Ayuthaya.ttf", 20 )
end

function ui:Update( dt )
	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.UpdateScreen then
			screen:UpdateScreen( dt )
		end
	end
end

function ui:RenderUI()
	love.graphics.setColor( 255, 255, 255 )

	for i = 1, #self.screens do
		local screen = self.screens[i]
		screen:RenderScreen( self )
	end
	table.clear( self.input.keys_pressed )
end

function ui:RegisterFont( style, font, sz )
	self.styles[ style ] = love.graphics.newFont( font, sz )
end

function ui:GetFont( style )
	return self.styles[ style ] or self.styles.default
end

function ui:WasPressed( key )
	return self.input.keys_pressed[ key ] ~= nil
end

function ui:GetSize()
	return love.graphics.getWidth(), love.graphics.getHeight()
end

---------------------------------------------

function ui:MouseMoved( x, y )
	self.input.mx, self.input.my = x, y

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.MouseMoved == nil or screen:MouseMoved( x, y ) then
			break
		end
	end
end

function ui:MousePressed( x, y, btn )
	self.input.clickx, self.input.clicky = x, y
	self.input.btns[ btn ] = true
	local now = love.timer.getTime()
	local double_click = self.input.time_pressed[ btn ] and now - self.input.time_pressed[ btn ] < 0.5
	self.input.time_pressed[ btn ] = now
	self:Log( "MousePressed %d, %d, %s", x, y, btn, double_click )

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.MousePressed == nil or screen:MousePressed( x, y, btn, double_click ) then
			break
		end
	end
end

function ui:MouseReleased( x, y, btn )
	self.input.clickx, self.input.clicky = nil, nil
	self.input.btns[ btn ] = nil
	self:Log( "MouseReleased %d, %d, %s", x, y, btn )

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.MouseReleased == nil or screen:MouseReleased( x, y, btn ) then
			break
		end
	end
end

function ui:MouseWheelMoved( x, y )
	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.MouseWheelMoved == nil or screen:MouseWheelMoved( x, y ) then
			break
		end
	end
end

function ui:KeyPressed( key )
	self.input.keys_pressed[ key ] = true

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.KeyPressed == nil or screen:KeyPressed( key ) then
			break
		end
	end
end

function ui:KeyReleased( key )
	self.input.keys_pressed[ key ] = false

	for i = #self.screens, 1, -1 do
		local screen = self.screens[i]
		if screen.KeyReleased == nil or screen:KeyReleased( key ) then
			break
		end
	end
end

----------------------------------------------

function ui:Screens()
	return ipairs( self.screens )
end

function ui:AddScreen( screen, idx )
	table.insert( self.screens, idx or #self.screens + 1, screen )
end

function ui:RemoveScreen( screen )
	table.arrayremove( self.screens, screen )
end

function ui:GetTopScreen()
	return self.screens[ #self.screens ]
end

function ui:FindScreen( class )
	assert( is_class( class ))
	for i, screen in ipairs( self.screens ) do
		if is_instance( screen, class ) then
			return screen
		end
	end
end

function ui:ClearScreens()
	while #self.screens > 0 do
		self:RemoveScreen( self.screens[ #self.screens ] )
	end
end

----------------------------------------------

function ui:Log( fmt, ... )
	table.insert( self.log, string.format( fmt, ... ))
	while #self.log > 100 do
		table.remove( self.log )
	end
end

----------------------------------------------

return ui
