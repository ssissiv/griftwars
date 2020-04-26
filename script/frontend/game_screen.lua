local GameScreen = class( "GameScreen", RenderScreen )

function GameScreen:init()
	RenderScreen.init( self )
	
	local gen = WorldGen()
	self.world = gen:GenerateWorld()
	self.nexus = WorldNexus( self.world, self )
	self.world:SetNexus( self.nexus )
	self.world:Start()
	self.world:ListenForAny( self, self.OnWorldEvent )

	-- List of objects and vergbs in the currently rendered location.
	self.objects = {}

	-- List of window panels.
	self.windows = {}

	self.zoom_level = 1.0
	self.camera = Camera()
	self.camera:SetViewPort( GetGUI():GetSize() )
	self.camera:ZoomToLevel( self.zoom_level )
	self:PanToCurrentInterest()

	self.world:SetPuppet( self.world:GetPlayer() )

	return self
end

function GameScreen:SaveWorld( filename )
	assert( filename )
	SerializeToFile( self.world, filename )
end

function GameScreen:LoadWorld( filename )
	assert( filename )
	self.world = DeserializeFromFile( filename )
end

function GameScreen:UpdateScreen( dt )
	self.world:UpdateWorld( dt )

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

function GameScreen:OnWorldEvent( event_name, world, ... )
	if event_name == WORLD_EVENT.PUPPET_CHANGED then
		local puppet = ...
		self:OnPuppetChanged( puppet )
	end
end

function GameScreen:OnPuppetChanged( puppet )
	if self.puppet then
		self.puppet:RemoveListener( self )
	end

	self.puppet = puppet
	self:PanToCurrentInterest()

	if puppet then
		if puppet.location then
			puppet.location:GenerateTileMap()
		end
		
		puppet:ListenForAny( self, self.OnPuppetEvent)
	end
end

function GameScreen:OnPuppetEvent( event_name, agent, ... )
	if event_name == AGENT_EVENT.LOCATION_CHANGED then
		self:PanToCurrentInterest()

	elseif event_name == AGENT_EVENT.TILE_CHANGED then
		self:RefreshVerbs()	 -- Hack: critical game state changed!
		self:PanToCurrentInterest()

	elseif event_name == AGENT_EVENT.COLLECT_VERBS then
		-- Verbs refreshed: if our current selected one is no lngoer valid, clear it.
		if self.current_verb then
			local verbs = ...
			if verbs:FindVerb( self.current_verb ) == nil then
				self:SetCurrentVerb( nil )
			end
		end
	end
end

function GameScreen:RenderScreen( gui )

	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove", "NoScrollBar", "NoBringToFrontOnFocus" }
	-- ui.SetNextWindowSize( love.graphics.getWidth(), 200 )
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

    self:RenderAgentDetails( ui, puppet )

    -- Render what the player is doing...
    for i, verb in puppet:Verbs() do
    	ui.TextColored( 0.8, 0.8, 0, 1.0, "ACTING:" )
    	ui.SameLine( 0, 10 )
    	ui.Text( loc.format( "{1} ({2#percent})", verb:GetDesc(), verb:GetActingProgress() or 1.0 ))

    	if verb:CanCancel() then
    		ui.SameLine( 0, 10 )
    		if ui.Button( "Cancel" ) then
    			puppet:Echo( "Nah, forget that." )
    			verb:Cancel()
    		end
    	end
    end
    ui.Separator()

    -- Render the things at the player's location.
    self:RenderLocationDetails( ui, puppet:GetLocation(), puppet )

    -- self:RenderPotentialVerbs( ui, puppet, "room" )

    self:RenderLocationTiles( puppet:GetLocation(), puppet )

    ui.End()

    -- if self.hovered_tile then
	    self:RenderHoveredLocation( gui, puppet )
	-- end

    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove" }
	ui.SetNextWindowSize( love.graphics.getWidth(), love.graphics.getHeight() * 0.25 )
	ui.SetNextWindowPos( 0, love.graphics.getHeight() * 0.75 )

    ui.Begin( "OUTPUT", true, flags )
	    self:RenderSenses( ui, puppet )
	ui.SetScrollHere()
    ui.End()

	for i, window in ipairs( self.windows ) do
		window:RenderImGuiWindow( ui, self )
	end

	self:RenderTooltip( ui )
end


function GameScreen:RenderHoveredLocation( gui, puppet )
	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoBringToFrontOnFocus" }
    local mx, my = love.mouse.getPosition()
	ui.SetNextWindowPos( mx + 20, my, 0 )

    if ui.Begin( "LOCATION", true, flags ) then
    	local hovered_tile, tx, ty = self:ScreenToTile( mx, my )
    	if hovered_tile then
	    	ui.TextColored( 0, 255, 255, 255, tostring(hovered_tile ))
	    	ui.Separator()
	    	for i, obj in hovered_tile:Contents() do
	    		local txt = obj:GetShortDesc( puppet )
	    		if txt then
		    		ui.Text( txt )
		    	end
	    	end
	    else
	    	ui.Text( string.format( "%d, %d", tx, ty ))
	    end
    end

    ui.End()
end


function GameScreen:AddWindow( window )
	for i, w in ipairs( self.windows ) do
		if w._class == window._class then
			if window.IsEqual == nil or window:IsEqual( w ) then
				table.remove( self.windows, i )
				table.insert( self.windows, w )
				return
			end
		end
	end

	table.insert( self.windows, window )
end

function GameScreen:RemoveWindow( window )
	table.arrayremove( self.windows, window )
end

function GameScreen:FindWindow( window )
	if table.contains( self.windows, window ) then
		return window
	end

	if is_class( window ) then
		for i, w in ipairs( self.windows ) do
			if w._class == window then
				return w
			end
		end
	end
end

function GameScreen:RenderAgentDetails( ui, puppet )
    ui.TextColored( 0.5, 1.0, 1.0, 1.0, puppet:GetName() )
    ui.SameLine( 0, 5 )
    if ui.SmallButton( "?" ) then
		self.nexus:Inspect( puppet, puppet )
	end

    ui.SameLine( 0, 40 )
    ui.TextColored( 1, 1, 0, 1, loc.format( "{1#money}", puppet:GetInventory():GetMoney() ))

    ui.SameLine( 0, 25 )

    local i = 1
    for stat, aspect in puppet:Stats() do
    	ui.SameLine( 0, 15 )
    	local value, max_value = aspect:GetValue()
    	if max_value then
	    	ui.Text( loc.format( "{1}: {2}/{3}", stat, value, max_value ))
	    else
	    	ui.Text( loc.format( "{1}: {2}", stat, value ))
	    end
	
		local growth = aspect:GetGrowth()
		if growth > 0 then
			ui.SameLine( 0, 5 )
			ui.TextColored( 0, 0.5, 0, 1, loc.format( "({1#percent})", growth ))
		end

    	i = i + 1
    end

 --    local tokens = puppet:GetAspect( Aspect.TokenHolder )
 --    if tokens then
 --    	local count, max_count = tokens:GetTokenCount()
 --    	for i = 1, max_count do
 --    		if i > 1 then
	-- 	    	ui.SameLine( 0, 15 )
	-- 	    end
	--     	local token = tokens:GetTokenAt( i )
	--     	if token then
	--     		ui.Text( "[" )
	--    			ui.SameLine( 0, 5 )
	--    			if token:IsCommitted() then
	-- 		    	ui.TextColored( 0.4, 0.4, 0.4, 1.0, tostring(token) )
	-- 		    	if ui.IsItemHovered() then
	-- 		    		if type(token.committed) == "table" then
	-- 			    		ui.SetTooltip( loc.format( "{1} ({2})", tostring(token.committed), Agent.GetAgentOwner( token.committed )))
	-- 			    	else
	-- 			    		ui.SetTooltip( tostring(token.committed) )
	-- 			    	end
	-- 		    	end
	--    			else
	-- 		    	ui.TextColored( 0.7, 0.7, 0.2, 1.0, tostring(token) )
	-- 		    end
	--    			ui.SameLine( 0, 5 )
	--     		ui.Text( "]" )
	-- 	    else
	-- 	    	ui.Text( "[ ]" )
	-- 	    end
	--     end
	-- end
end

function GameScreen:RenderLocationDetails( ui, location, puppet )
	if not location.map then
		return
	end

	local w, h = location.map:GetExtents()
	local x, y = self.camera:WorldToScreen( 1, 0 )

	love.graphics.setFont( assets.FONTS.TITLE )
	love.graphics.print( location:GetTitle(), x, y )

	if puppet:IsEnemy( location ) then
		love.graphics.setFont( assets.FONTS.SUBTITLE )
		self:SetColour( constants.colours.RED )
		love.graphics.print( "ENEMY", x, y - 16 )

	elseif puppet:IsAlly( location ) then
		love.graphics.setFont( assets.FONTS.SUBTITLE )
		self:SetColour( constants.colours.CYAN )
		love.graphics.print( "ALLY", x, y - 16 )
	end

	-- if not puppet:HasEngram( Engram.HasLearnedLocation, location ) then
	-- 	ui.SameLine( 0, 10 )
	-- 	if ui.SmallButton( "!") then
	-- 		puppet:GetMemory():AddEngram( Engram.LearnWhereabouts( location ))
	-- 	end
	-- end
end

function GameScreen:RenderPotentialVerbs( ui, agent, id, ... )
	ui.Indent( 20 )

	for i, verb in agent:PotentialVerbs( id, ... ) do
		local ok, details = verb:CanDo( agent, ... )
		local txt = loc.format( "{1}] {2}", i, verb:GetRoomDesc() )

		-- if agent:IsBusy() then
		-- 	ui.TextColored( 0.5, 0.5, 0.5, 1, txt )
		-- 	details = "You are already busy."

		if not ok then
			ui.TextColored( 0.5, 0.5, 0.5, 1, txt )
			details = details or "Can't do."

		else
			if verb.COLOUR then
				ui.PushStyleColor( "Text", Colour4( verb.COLOUR) )
			else
				ui.PushStyleColor( "Text", 1, 1, 0, 1 )
			end

			if ui.Selectable( txt ) then
				agent:DoVerbAsync( verb, ... )
			end

			ui.PopStyleColor()
		end

		if ui.IsItemHovered() and (details or verb.RenderTooltip) then
			ui.BeginTooltip()
			if verb.RenderTooltip then
				verb:RenderTooltip( ui, agent )
			end
			if details then
				ui.TextColored( 1, 1, 0.5, 1, details )
			end
			ui.EndTooltip()
		end
	end

	ui.Unindent( 20 )
end

function GameScreen:RenderLocationTiles( location, puppet )
	local W, H = GetGUI():GetSize()

	local wx0, wy0 = self.camera:ScreenToWorld( 0, 0 )
	wx0, wy0 = math.floor( wx0 ), math.floor( wy0 )
	local x0, y0 = self.camera:WorldToScreen( wx0, wy0 )

	local wx1, wy1 = self.camera:ScreenToWorld( W, H )
	wx1, wy1 = math.ceil( wx1 ), math.ceil( wy1 )
	local x1, y1 = self.camera:WorldToScreen( wx1, wy1 )

	self:RenderMapTiles( GetGUI(), location, wx0, wy0, wx1, wy1 )	
end

function GameScreen:RenderMapTiles( gui, location, wx0, wy0, wx1, wy1 )
	local xtiles = wx1 - wx0
	local ytiles = wy1 - wy0

	-- Render all map tiles.
	for dx = 1, xtiles do
		for dy = ytiles, 1, -1 do
			local tx, ty = wx0 + dx - 1, wy0 + dy - 1
			local tile = location:GetTileAt( tx, ty )
			if tile then
				local x1, y1 = self.camera:WorldToScreen( tx, ty )
				local x2, y2 = self.camera:WorldToScreen( tx + 1, ty + 1 )
				tile:RenderMapTile( self, x1, y1, x2, y2 )
			end
		end
	end

	if self.puppet then
		local verbs = self.puppet:GetPotentialVerbs( "room" )
		if self.active_tiles == nil then
			self.active_tiles = {}
		else
			table.clear( self.active_tiles )
		end
		local active_tile
		for i, verb in verbs:Verbs() do
			local tx, ty
			if verb:GetTarget() then
				tx, ty = AccessCoordinate( verb:GetTarget() )
			end
			if tx and ty then
				local tile = location:GetTileAt( tx, ty )
				table.insert_unique( self.active_tiles, tile )
				if verb == self.current_verb then
					active_tile = tile
				end
			end
		end

		for i, tile in ipairs( self.active_tiles ) do
			local tx, ty = tile:GetCoordinate()
			local x1, y1 = self.camera:WorldToScreen( tx, ty )
			local x2, y2 = self.camera:WorldToScreen( tx + 1, ty + 1 )
			local w, h = x2 - x1, y2 - y1

			if tile == active_tile then
				love.graphics.setColor( 255, 255, 0, 255 )
			else
				love.graphics.setColor( 255, 255, 255, 255 )
			end
			self:Box(x1, y1, w, h )
			self:Box(x1 + 1, y1 + 1, w - 2, h - 2 )
		end
	end

	if self.hoverx and self.hovery then
		local x1, y1 = self.camera:WorldToScreen( self.hoverx, self.hovery )
		local x2, y2 = self.camera:WorldToScreen( self.hoverx + 1, self.hovery + 1 )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( "line", x1, y1, x2 - x1, y2 - y1 )
	end
end

function GameScreen:RenderBackground( ui, agent )
    local _, h = ui:GetWindowSize()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor( 255, 255, 255 )

	-- Render the background image
    if agent:GetLocation() and agent:GetLocation():GetImage() then
	    -- love.graphics.rectangle( "fill", 0, h, W, H * 0.75 - h )
	    love.graphics.draw( agent:GetLocation():GetImage(), 0, h )
	end

	if is_instance( agent:GetFocus(), Agent ) then
		-- head
	    love.graphics.setColor( table.unpack( agent:GetFocus().viz.skin_colour ))
		love.graphics.circle( "fill", W/2, h + 150, 100 )

		-- eyes
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.circle( "line", W/2 - 30, h + 150 - 20, 20 )
		love.graphics.circle( "line", W/2 + 30, h + 150 - 20, 20 )

		-- pupils
		love.graphics.setColor( 0, 60, 90 )
		love.graphics.circle( "fill", W/2 - 30, h + 150 - 10, 10 )
		love.graphics.circle( "fill", W/2 + 30, h + 150 - 10, 10 )

		-- nose
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.line( W/2 + 5, h + 175, W/2, h + 179 )

		-- mouth
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.line( W/2 - 40, h + 190, W/2 - 30, h + 200 )
		love.graphics.line( W/2 - 30, h + 200, W/2 + 30, h + 200 )
		love.graphics.line( W/2 + 30, h + 200, W/2 + 40, h + 190 )
	end
end

function GameScreen:GetDebugEnv( env )
	env.player = self.world:GetPlayer()
end

function GameScreen:RenderSenses( ui, agent )
	local now = self.world:GetDateTime()
	for i, sense in agent:Senses() do
		if sense.when then
			local elapsed = now - sense.when
			local duration, r, g, b, a

			if sense.sensor_type == SENSOR.ECHO then
				duration = HALF_HOUR
				r, g, b = 1, 1, 1
			else
				duration = 10 * ONE_MINUTE
				r, g, b = 1, 1, 0.4
			end

			-- Keep things around along multiplier
			duration = duration * 5

			if duration then
				a = 1.0 - clamp( elapsed / duration, 0, 1.0 )
			else
				a = 1.0
			end
			if a > 0.0 then
				ui.TextColored( r, g, b, a, tostring(sense.desc))
			end
		end
	end
end

function GameScreen:ScreenToCell( mx, my )
	local wx, wy = self.camera:ScreenToWorld( mx, my )
	return math.floor( wx ), math.floor( wy )
end

function GameScreen:ScreenToTile( mx, my )
	local cx, cy = self:ScreenToCell( mx, my )
	local puppet = self.world:GetPuppet()
	if puppet and puppet:GetLocation() then
		return puppet:GetLocation():GetTileAt( cx, cy ), cx, cy
	end
end

function GameScreen:Pan( px, py )
	local screenw, screenh = love.graphics.getWidth(), love.graphics.getHeight()
	local x0, y0 = self.camera:ScreenToWorld( 0, 0 )
	local x1, y1 = self.camera:ScreenToWorld( screenw * px, screenh * py )
	local dx, dy = x1 - x0, y1 - y0
	self.camera:Pan( dx, dy )
end

function GameScreen:PanTo( x, y )
	local x1, y1 = self.camera:ScreenToWorld( 0, 0 )
	local x2, y2 = self.camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )

	self.camera:PanTo( x - (x2 - x1 - 1)/2, y - (y2 - y1 - 1)/2 )
end

function GameScreen:PanToCurrentInterest()
	if self.current_verb then
		local tx, ty = AccessCoordinate( self.current_verb:GetTarget() or self.puppet )
		if tx and ty then
			self:PanTo( tx, ty )
		end

	else
		local cx, cy
		if self.puppet then
			cx, cy = self.puppet:GetCoordinate()
			if cx then
				self:WarpCameraTo( cx, cy )
			end
		end
	end	
end

function GameScreen:WarpCameraTo( x, y )
	local x1, y1 = self.camera:ScreenToWorld( 0, 0 )
	local x2, y2 = self.camera:ScreenToWorld( love.graphics.getWidth(), love.graphics.getHeight() )

	self.camera:WarpTo( x - (x2 - x1 - 1)/2, y - (y2 - y1 - 1)/2 )
end

function GameScreen:CycleVerbs()
	if not self.puppet then
		return
	end

	local verbs = self.puppet:GetPotentialVerbs( "room" )
	verbs:SortByDistanceTo( self.puppet:GetCoordinate() )

	local idx = verbs:FindVerb( self.current_verb ) or 0
	local x0, y0
	if self.current_verb then
		x0, y0 = AccessCoordinate( self.current_verb:GetTarget() or self.puppet )
	end
	for j = 1, verbs:CountVerbs() do
		local k = (idx + j - 1) % verbs:CountVerbs() + 1
		local next_verb = verbs:VerbAt( k )
		if next_verb:GetTarget() then
			local x1, y1 = AccessCoordinate( next_verb:GetTarget() or self.puppet )
			if x1 ~= x0 or y1 ~= y0 then
				idx = k
				break
			end
		end
	end

	self:SetCurrentVerb( verbs:VerbAt( idx ) )
end

function GameScreen:RefreshVerbs()
	self.puppet:RegenVerbs()
	self:SetCurrentVerb( self.current_verb )
end

function GameScreen:SetCurrentVerb( verb )
	self.current_verb = verb

	local verb_window = self:FindWindow( VerbMenu )
	if verb_window == nil and verb ~= nil then
		-- Show window.
		verb_window = VerbMenu( self.world )
		self:AddWindow( verb_window )

	elseif verb_window and verb == nil then
		-- No verb: clear window.
		self:RemoveWindow( verb_window )
		verb_window = nil
	end

	if verb_window then
		-- Refresh verb window.
		local verbs = self.puppet:GetPotentialVerbs( "room" )
		verb_window:RefreshContents( self.puppet, verb, verbs )
	end

	self:PanToCurrentInterest()
	print( "CURRENT VERB:", self.current_verb)
end

function GameScreen:GetVerbAt( mx, my )
	local x, y = self:ScreenToCell( mx, my )
	local verbs = self.puppet:GetPotentialVerbs()
	for i, verb in verbs:Verbs() do
        local tx, ty
        if verb:GetTarget() then
			tx, ty = AccessCoordinate( verb:GetTarget() )
		else
			tx, ty = self.puppet:GetCoordinate()
		end
        if tx == x and ty == y then
        	return verb
        end
    end
end

function GameScreen:MouseMoved( mx, my )
	if love.keyboard.isDown( "space" ) then
		if self.is_panning then
			local x1, y1 = self.camera:ScreenToWorld( mx, my )
			local x0, y0 = self.camera:ScreenToWorld( self.pan_start_mx, self.pan_start_my )
			self.camera:WarpTo( self.pan_start_x - (x1 - x0), self.pan_start_y - (y1 -y0) )
		end
	end
end

function GameScreen:MousePressed( mx, my, btn )
	for i, window in ipairs( self.windows ) do
		if window.MousePressed and window:MousePressed( mx, my, btn ) then
			return true
		end
	end

	if self.hovered_tile then
		if Input.IsControl() then
			DBG(self.hovered_tile)
			return true
		else
			local verb = self:GetVerbAt( mx, my )
			self:SetCurrentVerb( verb )
			return true
		end
	end

	return false
end

function GameScreen:KeyPressed( key )
	for i, window in ipairs( self.windows ) do
		if window.KeyPressed and window:KeyPressed( key, self ) then
			return true
		end
	end

	local pan_delta = Input.IsShift() and 0.5 or 0.1

	if key == "space" then
		self.is_panning = true
		self.pan_start_x, self.pan_start_y = self.camera:GetPosition()
		self.pan_start_mx, self.pan_start_my = love.mouse.getPosition()

	elseif key == "i" then
		if self.inventory_window then
			self:RemoveWindow( self.inventory_window )
			self.inventory_window = nil
		else
			local puppet = self.world:GetPuppet()
			self.inventory_window = InventoryWindow( puppet, puppet )
			self:AddWindow( self.inventory_window )
		end
		return true

	elseif key == "c" then
		local window = self:FindWindow( AgentDetailsWindow )
		if window then
			self:RemoveWindow( window )
		else
			local puppet = self.world:GetPuppet()
			self:AddWindow( AgentDetailsWindow( puppet, puppet ))
		end

	elseif key == "k" then
		local window = self:FindWindow( MemoryWindow )
		if window then
			self:RemoveWindow( window )
		else
			self:AddWindow( MemoryWindow( self.world:GetPuppet() ))
		end

	elseif key == "m" then
		local screen = MapScreen( self.world )
		GetGUI():AddScreen( screen )

	elseif key == "left" or key == "a" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() then
			puppet:Walk( EXIT.WEST )
		end

	elseif key == "right" or key == "d" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() then
			puppet:Walk( EXIT.EAST )
		end

	elseif key == "up" or key == "w" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() then
			puppet:Walk( EXIT.SOUTH )
		end

	elseif key == "down" or key == "s" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() then
			puppet:Walk( EXIT.NORTH )
		end

	elseif key == "." then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) then
			if Input.IsShift() then
				puppet:AttemptVerb( Verb.LeaveLocation )
			else
				puppet:AttemptVerb( Verb.Wait )
			end
		end

	elseif key == "tab" then
		self:CycleVerbs()

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

function GameScreen:KeyReleased( key )
	if key == "space" then
		self.is_panning = false
		return true
	end
end
