local MapScreen = class( "MapScreen", RenderScreen )

function MapScreen:init( world )
	RenderScreen.init( self )
	self.world = world

	self.elapsed_time = 0

	self.zoom_level = 0
	self.camera = Camera()
	self.camera:SetViewPort( GetGUI():GetSize() )
	self.camera:ZoomToLevel( self.zoom_level )
end

function MapScreen:ElapsedTime()
	return self.elapsed_time
end

function MapScreen:UpdateScreen( dt )
	self.camera:UpdateCamera( dt )

	self.elapsed_time = self.elapsed_time + dt

	if self.is_panning then
		self.hovered_tile = nil
	else
		local mx, my = love.mouse.getPosition()
		self.hovered_tile = self:ScreenToTile( mx, my )

		-- Calculate hover tile coordinates
		local wx, wy = self.camera:ScreenToWorld( mx, my )
		wx, wy = math.floor( wx ), math.floor( wy )
		self.hoverx, self.hovery = wx, wy
	end
end

function MapScreen:RenderHeader( gui )
	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove", "NoScrollBar", "NoBringToFrontOnFocus" }
--	ui.SetNextWindowSize( love.graphics.getWidth(), 40 )
	ui.SetNextWindowPos( 0, 0 )

    ui.Begin( "ROOM", true, flags )
    local puppet = self.world:GetPuppet()

    -- Render details about the player.
    local use_seconds = self.world:CalculateTimeElapsed( 1.0 ) < 1/60
    local timestr = Calendar.FormatTime( self.world:GetDateTime(), use_seconds )
    ui.Text( timestr )
    if self.world:IsPaused() then
    	ui.SameLine( 0, 10 )
    	ui.Text( "(PAUSED)" )
    end
    local dt = self.world:CalculateTimeElapsed( 1.0 )
    if dt ~= WALL_TO_GAME_TIME then
    	ui.SameLine( 0, 10 )
    	ui.Text( string.format( "(x%.2f)", dt / WALL_TO_GAME_TIME))
    end

    ui.Separator()

    local mx, my = love.mouse.getPosition()
    ui.Text( loc.format( "{1}, {2}", self:ScreenToCell( mx, my ) ))

    if self.hovered_tile then
    	ui.TextColored( 0, 255, 255, 255, tostring(self.hovered_tile))
    end

    ui.End()
end

function MapScreen:RenderScreen( gui )

	self:RenderHeader( gui )

	local W, H = gui:GetSize()
	local wx0, wy0 = self.camera:ScreenToWorld( 0, 0 )
	wx0, wy0 = math.floor( wx0 ), math.floor( wy0 )
	local x0, y0 = self.camera:WorldToScreen( wx0, wy0 )

	local wx1, wy1 = self.camera:ScreenToWorld( W, H )
	wx1, wy1 = math.ceil( wx1 ), math.ceil( wy1 )
	local x1, y1 = self.camera:WorldToScreen( wx1, wy1 )

	self:RenderMapTiles( gui, wx0, wy0, wx1, wy1 )

	if self.hovered_tile then
		self:RenderHoveredLocation( gui )
	end
end

function MapScreen:RenderHoveredLocation( gui )
	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoBringToFrontOnFocus" }
    local mx, my = love.mouse.getPosition()
	ui.SetNextWindowPos( mx + 20, my, 0 )

    if ui.Begin( "LOCATION", true, flags ) then
    	ui.TextColored( 0, 255, 255, 255, tostring(self.hovered_tile ))
    	ui.Separator()
    	for i, obj in self.hovered_tile:Contents() do
    		ui.Text( tostring(obj) )
    	end
    end

    ui.End()
end

function MapScreen:RenderMapTiles( gui, wx0, wy0, wx1, wy1 )
	local xtiles = wx1 - wx0
	local ytiles = wy1 - wy0

	-- Render all map tiles.
	for dx = 1, xtiles do
		for dy = ytiles, 1, -1 do
			local tx, ty = wx0 + dx - 1, wy0 + dy - 1
			local tile = self.world:GetLocationAt( tx, ty )
			if tile then
				local x1, y1 = self.camera:WorldToScreen( tx, ty )
				local x2, y2 = self.camera:WorldToScreen( tx + 1, ty + 1 )
				tile:RenderLocationOnMap( self, x1, y1, x2, y2 )
			end
		end
	end

	if self.hoverx and self.hovery then
		local x1, y1 = self.camera:WorldToScreen( self.hoverx, self.hovery )
		local x2, y2 = self.camera:WorldToScreen( self.hoverx + 1, self.hovery + 1 )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( "line", x1, y1, x2 - x1, y2 - y1 )
	end
end

function MapScreen:ScreenToCell( mx, my )
	local wx, wy = self.camera:ScreenToWorld( mx, my )
	return math.floor( wx ), math.floor( wy )
end

function MapScreen:ScreenToTile( mx, my )
	local cx, cy = self:ScreenToCell( mx, my )
	return self.world:GetLocationAt( cx, cy ), cx, cy
end

function MapScreen:Pan( px, py )
	local screenw, screenh = love.graphics.getWidth(), love.graphics.getHeight()
	local x0, y0 = self.camera:ScreenToWorld( 0, 0 )
	local x1, y1 = self.camera:ScreenToWorld( screenw * px, screenh * py )
	local dx, dy = x1 - x0, y1 - y0
	self.camera:Pan( dx, dy )
end

function MapScreen:PanTo( x, y )
	local x1, y1 = self.camera:ScreenToWorld( 0, 0 )
	local x2, y2 = self.camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )

	self.camera:PanTo( x - (x2 - x1 - 1)/2, y - (y2 - y1 - 1)/2 )
end

function MapScreen:MoveTo( x, y )
	local x1, y1 = self.camera:ScreenToWorld( 0, 0 )
	local x2, y2 = self.camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )

	self.camera:MoveTo( x - (x2 - x1 - 1)/2, y - (y2 - y1 - 1)/2 )
end

function MapScreen:MouseMoved( mx, my )
	if love.keyboard.isDown( "space" ) then
		if self.is_panning then
			local x1, y1 = self.camera:ScreenToWorld( mx, my )
			local x0, y0 = self.camera:ScreenToWorld( self.pan_start_mx, self.pan_start_my )
			self.camera:MoveTo( self.pan_start_x - (x1 - x0), self.pan_start_y - (y1 -y0) )
		end
	end
end

function MapScreen:MousePressed( mx, my, btn )
	if self.hovered_tile then
		DBG(self.hovered_tile)
		return true
	end
	return false
end

function MapScreen:KeyPressed( key )

	if key == "m" then
		GetGUI():RemoveScreen( self )
		return true
	end

	local pan_delta = Input.IsShift() and 0.5 or 0.1

	if key == "space" then
		self.is_panning = true
		self.pan_start_x, self.pan_start_y = self.camera:GetPosition()
		self.pan_start_mx, self.pan_start_my = love.mouse.getPosition()

	elseif key == "backspace" then
		self:PanTo( 0, 0 )
	elseif key == "left" or key == "a" then
		self:Pan( -pan_delta, 0 )
	elseif key == "right" or key == "d" then
		self:Pan( pan_delta, 0 )
	elseif key == "up" or key == "w" then
		self:Pan( 0, -pan_delta )
	elseif key == "down" or key == "s" then
		self:Pan( 0, pan_delta )
	elseif key == "=" then
		self.zoom_level = math.min( (self.zoom_level + 1), 3 )
		local mx, my = love.mouse.getPosition()
		self.camera:ZoomToLevel( self.zoom_level, mx, my )

	elseif key == "-" then
		self.zoom_level = math.max( (self.zoom_level - 1), -3 )
		local mx, my = love.mouse.getPosition()
		self.camera:ZoomToLevel( self.zoom_level, mx, my )
	end

	return true
end


function MapScreen:MouseWheelMoved( dx, dy )
	dy = dy / 10
	if dy > 0 then
		self.zoom_level = math.min( (self.zoom_level + dy ), 3 )
	elseif dy < 0 then
		self.zoom_level = math.max( (self.zoom_level + dy ), -3 )
	end

	local mx, my = love.mouse.getPosition()
	self.camera:ZoomToLevel( self.zoom_level, mx, my )
	return true
end

function MapScreen:KeyReleased( key )
	if key == "space" then
		self.is_panning = false
		return true
	end
end

