YIELD_CMD = MakeEnum{
	"WAIT",
	"LOCATION",
	"PAN_TILE",
	"CAPTION",
}

local LoadScreen = class( "LoadScreen", RenderScreen )

function LoadScreen:init( worldgen )
	RenderScreen.init( self )
	
	self.worldgen = worldgen
	self.zoom_level = 1.0
	self.camera = Camera()
	self.camera:SetViewPort( 0, 0, GetGUI():GetSize() )
	self.camera:ZoomToLevel( self.zoom_level )

	self.yield_cmds = {}
	self.captions = {}

	self:GenerateWorld()

	return self
end

function LoadScreen:GenerateWorld()
    local gen
    local function GenerateWorldCoro()
        gen = WorldGen()
        local world = gen:GenerateWorld()
        return world
    end

    self.worldgen_coro = coroutine.create( GenerateWorldCoro )
end

function LoadScreen:GetDebugEnv( env )
	env.location = self.location
end


function LoadScreen:ScreenToCell( mx, my )
	local wx, wy = self.camera:ScreenToWorld( mx, my )
	return math.floor( wx ), math.floor( wy )
end

function LoadScreen:ScreenToTile( mx, my )
	local cx, cy = self:ScreenToCell( mx, my )
	if self.location then
		return self.location:LookupTile( cx, cy ), cx, cy
	end
end

function LoadScreen:Pan( px, py )
	local screenw, screenh = love.graphics.getWidth(), love.graphics.getHeight()
	local x0, y0 = self.camera:ScreenToWorld( 0, 0 )
	local x1, y1 = self.camera:ScreenToWorld( screenw * px, screenh * py )
	local dx, dy = x1 - x0, y1 - y0
	self.camera:Pan( dx, dy )
end

function LoadScreen:PanTo( x, y )
	local x1, y1 = self.camera:ScreenToWorld( 0, 0 )
	local x2, y2 = self.camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )

	self.camera:PanTo( x - (x2 - x1 - 1)/2, y - (y2 - y1 - 1)/2 )
end

function LoadScreen:FindLocationInCoro()
        -- go through the coro stack.
    local i = 1
    while true do
    	local db = debug.getinfo( self.worldgen_coro, i )
    	if not db then
    		break
    	end
    	local j = 1
    	while true do
    		local k, v = debug.getlocal( self.worldgen_coro, i, j)
    		if k == "self" and is_instance( v, Location ) and self.location == nil then
    			return v
    		end
    		if k == nil or v == nil then
    			break
    		end
    		j = j + 1
    	end
    	i = i + 1
    end
end


function LoadScreen:UpdateScreen( dt )
	RenderScreen.UpdateScreen( self, dt )

	if self:ProcessYield( dt ) then
		-- processing yield
	else
		if self.worldgen_coro and coroutine.status( self.worldgen_coro ) == "suspended" then
		    local result = { coroutine.resume( self.worldgen_coro ) }
		    local ok = table.remove( result, 1 )
		    if not ok then
		        self.error_trace = "Failed worldgen: " ..tostring(result) .. "\n".. debug.traceback( self.worldgen_coro )
		        print( self.error_trace )
		        self.location = self:FindLocationInCoro()

		        DBG(self.worldgen_coro)
		        if self.location then
			        self:PanTo( 0, 0 )
			    end

		    elseif coroutine.status( self.worldgen_coro ) == "suspended" then
		    	if type(result) == "table" then
		    		table.arrayadd( self.yield_cmds, result )
		    	end
			else
		        assert( is_instance( result[1], World ))
		        self:FadeToBlack( function() 
		        	self:CloseScreen()

			        local game = GameScreen( result[1] )
			        GetGUI():AddScreen( game, 1 )

			        game:FadeFromBlack()
		       end )

		    end
		end
	end

	self:UpdateCaptions( dt )

	self.camera:UpdateCamera( dt )

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

function LoadScreen:ProcessYield( dt )

	-- If waiting, ...
	if self.yield_wait then
		self.yield_wait = self.yield_wait - dt
		if self.yield_wait > 0 then
			return true
		end
	end
	-- Waiting on captions...
	if #self.captions > 0 then
		return true
	end

	if #self.yield_cmds == 0 then
		return
	end

	local cmd = table.remove( self.yield_cmds, 1 )
	if not IsEnum( cmd, YIELD_CMD ) then
		print( "invalid yield cmd:", tostr(result))
		return
	end

	if cmd == YIELD_CMD.WAIT then
		self.yield_wait = table.remove( self.yield_cmds, 1 )
		assert( self.yield_wait > 0 )
		return true

	elseif cmd == YIELD_CMD.PAN_TILE then
		local tile = table.remove( self.yield_cmds, 1 )
		self:PanTo( tile.x, tile.y )
		return true

	elseif cmd == YIELD_CMD.LOCATION then
		self.location = table.remove( self.yield_cmds, 1 )
		assert( is_instance( self.location, Location ))
		self:PanTo( 0, 0 )

	elseif cmd == YIELD_CMD.CAPTION then
		local txt = table.remove( self.yield_cmds, 1 )
		local x = table.remove( self.yield_cmds, 1 )
		local y = table.remove( self.yield_cmds, 1 )
		local duration = table.remove( self.yield_cmds, 1 )
		self:ShowCaption( txt, x, y, duration )
	end
end

function LoadScreen:ShowCaption( txt, x, y, duration )
	local caption =
	{
		txt = txt,
		x = x,
		y = y,
		duration = duration,
		dt = 0,
	}
	table.insert( self.captions, caption )
end

function LoadScreen:UpdateCaptions( dt )
	for i = #self.captions, 1, -1 do
		local caption = self.captions[i]
		caption.dt = caption.dt + dt
		if caption.dt >= caption.duration + 0.5 then
			table.remove( self.captions, i )
		end
	end
end

function LoadScreen:RenderCaptions( dt )
	for i = #self.captions, 1, -1 do
		local caption = self.captions[i]

		local x, y = self.camera:WorldToScreen( caption.x, caption.y )
		local a = 1.0
		if caption.dt >= caption.duration then
			a = 1.0 - clamp( (caption.dt - caption.duration) / 0.5, 0, 1.0 )
		end

		self:DebugText( x, y, caption.txt, AlphaColour( 0xFFFFFFFF, a ))
	end
end


function LoadScreen:RenderHoveredLocation( gui )
	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoBringToFrontOnFocus" }
    local mx, my = love.mouse.getPosition()
	ui.SetNextWindowPos( mx + 20, my, 0 )

    if ui.Begin( "LOCATION", true, flags ) then
    	local hovered_tile, tx, ty = self:ScreenToTile( mx, my )
    	if hovered_tile then
	    	ui.TextColored( 0, 1, 1, 1, tostring(hovered_tile ))
	    	ui.Separator()
	    	for i, obj in hovered_tile:Contents() do
	    		local txt = obj:GetShortDesc( nil )
	    		if txt then
		    		ui.Text( txt )
		    	end
	    	end
	    elseif tx and ty then
	    	ui.Text( string.format( "%d, %d", tx, ty ))
	    end
    end

    ui.End()
end

function LoadScreen:OnRenderScreen( gui )
	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove", "NoScrollBar", "NoBringToFrontOnFocus" }
	-- ui.SetNextWindowSize( love.graphics.getWidth(), 200 )
	ui.SetNextWindowPos( 0, 0 )

    ui.Begin( "ROOM", true, flags )

    ui.Dummy( love.graphics.getWidth(), 0 )
    if self.worldgen_coro and ui.SmallButton( "?" ) then
    	DBG( self.worldgen_coro )
    end
	if self.error_trace then
	    ui.TextColored( 1, 0, 0, 1, tostring(self.error_trace) )
	end
	self.top_height = ui.GetWindowHeight() 
    ui.End()


   	if self.location then
	    self:RenderLocationTiles( self.location )
	end

    if self.hovered_tile then
	    self:RenderHoveredLocation( gui )
	else
		ui.SetTooltip( string.format( "(%.1f, %.1f)", self:ScreenToCell( love.mouse.getPosition() )))
	end

	self:RenderCaptions()
end


function LoadScreen:RenderLocationTiles( location )
	local W, H = GetGUI():GetSize()

	local wx0, wy0 = self.camera:ScreenToWorld( 0, self.top_height )
	wx0, wy0 = math.floor( wx0 ), math.floor( wy0 )
	local x0, y0 = self.camera:WorldToScreen( wx0, wy0 )

	local wx1, wy1 = self.camera:ScreenToWorld( W, H )
	wx1, wy1 = math.ceil( wx1 ), math.ceil( wy1 )
	local x1, y1 = self.camera:WorldToScreen( wx1, wy1 )

	self:RenderMapTiles( GetGUI(), location, wx0, wy0, wx1, wy1 )	
end

function LoadScreen:RenderMapTiles( gui, location, wx0, wy0, wx1, wy1 )
	local xtiles = wx1 - wx0
	local ytiles = wy1 - wy0

	self.ymax = 0
	-- Render all map tiles.
	for dx = 1, xtiles do
		for dy = ytiles, 1, -1 do
			local tx, ty = wx0 + dx - 1, wy0 + dy - 1
			local tile = location:LookupTile( tx, ty )
			if tile then
				local x1, y1 = self.camera:WorldToScreen( tx, ty )
				local x2, y2 = self.camera:WorldToScreen( tx + 1, ty + 1 )
				tile:RenderMapTile( self, x1, y1, x2, y2 )
			end
		end
	end

	-- Render map tile content
	for dx = 1, xtiles do
		for dy = ytiles, 1, -1 do
			local tx, ty = wx0 + dx - 1, wy0 + dy - 1
			local tile = location:LookupTile( tx, ty )
			if tile then
				local x1, y1 = self.camera:WorldToScreen( tx, ty )
				local x2, y2 = self.camera:WorldToScreen( tx + 1, ty + 1 )
				for i, obj in tile:Contents() do
					if obj.RenderMapTile then
						obj:RenderMapTile( self, tile, x1, y1, x2, y2 )
					end
				end
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

function LoadScreen:MouseMoved( mx, my )
	if love.keyboard.isDown( "space" ) then
		if self.is_panning then
			local x1, y1 = self.camera:ScreenToWorld( mx, my )
			local x0, y0 = self.camera:ScreenToWorld( self.pan_start_mx, self.pan_start_my )
			self.camera:WarpTo( self.pan_start_x - (x1 - x0), self.pan_start_y - (y1 -y0) )
		end
	end
end

function LoadScreen:KeyPressed( key )
	local pan_delta = Input.IsShift() and 0.5 or 0.1

	if key == "left" or key == "a" then
		self:Pan( -0.2, 0 )

	elseif key == "right" or key == "d" then
		self:Pan( 0.2, 0 )

	elseif key == "up" or key == "w" then
		self:Pan( 0, -0.2 )

	elseif key == "down" or key == "s" then
		self:Pan( 0, 0.2 )

	elseif key == "space" then
		self.is_panning = true
		self.pan_start_x, self.pan_start_y = self.camera:GetPosition()
		self.pan_start_mx, self.pan_start_my = love.mouse.getPosition()

	elseif key == "=" then
		self.zoom_level = math.min( (self.zoom_level + 1), 3 )
		local mx, my = love.mouse.getPosition()
		self.camera:ZoomToLevel( self.zoom_level, mx, my )

	elseif key == "-" then
		self.zoom_level = math.max( (self.zoom_level - 1), -3 )
		local mx, my = love.mouse.getPosition()
		self.camera:ZoomToLevel( self.zoom_level, mx, my )
	end

	return false
end

function LoadScreen:KeyReleased( key )
	if key == "space" then
		self.is_panning = false
		return true
	end
end

function LoadScreen:MouseWheelMoved( dx, dy )
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

