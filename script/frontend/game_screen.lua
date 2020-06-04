local GameScreen = class( "GameScreen", RenderScreen )

function GameScreen:init( world )
	RenderScreen.init( self )
	
	if world == nil then
		local gen = WorldGen()
		world = gen:GenerateWorld()
		world:Start()
	end
	self.world = world
	self.nexus = WorldNexus( self.world, self )
	self.world:SetNexus( self.nexus )
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

	GetDbg().game = self
	
	return self
end

function GameScreen:CloseScreen()
	self.world:RemoveListener( self )
	GetGUI():RemoveScreen( self )
end

function GameScreen:SaveWorld( filename )
	assert( filename )
	SerializeToFile( self.world, filename )
	print( "Saved to", filename )
end

function GameScreen:LoadWorld( filename )
	assert( filename )
	print( "Loading from ", filename )
	local world = DeserializeFromFile( filename )
	GetGUI():AddScreen( GameScreen( world ))
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

	elseif event_name == WORLD_EVENT.PAUSED then
		-- Refresh focus validity, and verbs
		self:SetCurrentFocus( self.current_focus )
	end
end

function GameScreen:OnPuppetChanged( puppet )
	if self.puppet then
		self.puppet:RemoveListener( self )
	end

	self.puppet = puppet
	self:PanToCurrentInterest()

	if puppet then
		puppet:ListenForAny( self, self.OnPuppetEvent)
	end
end

function GameScreen:OnPuppetEvent( event_name, agent, ... )
	if event_name == AGENT_EVENT.LOCATION_CHANGED then
		local location, prev_location = ...
		self:SetCurrentFocus( nil )
		self:PanToCurrentInterest()
		local screen = GetGUI():FindScreen( MapScreen )
		if screen then
			screen:SetLocation( location )
		end

	elseif event_name == AGENT_EVENT.TILE_CHANGED then
		-- if not self.lock_focus then
		-- 	self:SetCurrentFocus( nil )
		-- else
			local verb_window = self:FindWindow( VerbMenu )
			if verb_window then
				verb_window:RefreshContents( self.puppet, self.current_focus )
			end
		-- end
		self:PanToCurrentInterest()

	elseif event_name == AGENT_EVENT.DIED then
		self:SetCurrentFocus( nil )
	end
end

function GameScreen:RenderScreen( gui )

	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove", "NoScrollBar", "NoBringToFrontOnFocus" }
	-- ui.SetNextWindowSize( love.graphics.getWidth(), 200 )
	ui.SetNextWindowPos( 0, 0 )

    ui.Begin( "ROOM", true, flags )
    local puppet = self.world:GetPuppet()

    ui.Dummy( love.graphics.getWidth(), 0 )

    -- Render details about the player.
    local use_seconds = self.world:CalculateTimeElapsed( 1.0 ) < 1/60 or (puppet and puppet:InCombat())
    local timestr = Calendar.FormatDateTime( self.world:GetDateTime(), use_seconds )
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

    -- Render what the player is doing...
    for i, verb in puppet:Verbs() do
		ui.SameLine( 0, 10 )
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

    self:RenderAgentDetails( ui, puppet )

    -- Render Combat targets
    local combat = puppet:GetAspect( Aspect.Combat )
    if combat and puppet:InCombat() then
    	ui.Separator()

    	-- Allies.
		local hp, max_hp = puppet:GetHealth()
		ui.TextColored( 0, 1, 0, 1, loc.format( "{1.Id} - {2}/{3}",
			puppet:LocTable( self.puppet ), hp, max_hp ))

		ui.SameLine( 0, 50 )
    	local wpn = puppet:GetInventory():AccessSlot( EQ_SLOT.WEAPON )
    	ui.Text( loc.format( "{1} damage:", wpn and wpn:GetName( puppet ) or "Unarmed" ))
    	local show_tt = ui.IsItemHovered()
    	ui.SameLine( 0 )
    	local damage, details = puppet:CalculateAttackPower()
    	ui.TextColored( 0, 1, 1, 1, tostring(damage))
    	show_tt = show_tt or ui.IsItemHovered()
    	if show_tt and details then
    		ui.SetTooltip( details )
    	end

    	for i, target in combat:Targets() do
    		local hp, max_hp = target:GetHealth()
    		local txt = loc.format( "{1.Id} - {2}/{3}", target:LocTable( self.puppet ), hp, max_hp )
    		if self.current_focus == target:GetTile() then
    			ui.TextColored( 1.0, 0, 0, 1.0, ">>" ..txt )
    		else
    			ui.TextColored( 0.5, 0, 0, 1.0, txt )
    		end
    		local attack = target:GetAspect( Aspect.Combat ):GetCurrentAttack()
    		if attack then
    			local t = attack:GetActingProgress()
    			if t then
	    			ui.SameLine( 0, 50 )
	    			local time_left, total_time = attack:GetActingTime()
	    			ui.Text( loc.format( "{1} {2%.2d} ({3})", attack:GetDesc(),
	    				t, Calendar.FormatDuration( total_time )) )
	    			ui.SameLine( 0, 50 )

			    	local damage, details = attack:CalculateDamage( attack:GetTarget() )
	    			ui.Text( loc.format( "{1} damage", damage ))

					if ui.IsItemHovered() then
			    		ui.SetTooltip( details )
    				end
	    		end
    		end
    	end
    end
    ui.Separator()

    local location = puppet and puppet:GetLocation() or self.last_location
    if location then
	    -- Render the things at the player's location.
	    self:RenderLocationDetails( ui, location )

	    self:RenderLocationTiles( location, puppet )

	    self.last_location = location
	end

    self:RenderSenses( ui, puppet )
	ui.SetScrollHere()

    ui.End()

    -- if self.hovered_tile then
	    self:RenderHoveredLocation( gui, puppet )
	-- end

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
	    	ui.TextColored( 0, 1, 1, 1, tostring(hovered_tile ))
	    	ui.Separator()
	    	for i, obj in hovered_tile:Contents() do
	    		local txt = obj:GetShortDesc( puppet )
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

    local xp = puppet:GetStatValue( STAT.XP )
    ui.Text( loc.format( "XP: {1}", xp ))
    ui.SameLine( 0, 15 )
    ui.TextColored( 1, 0, 0, 1, loc.format( "HP: {1}/{2}", puppet:GetHealth() ))

	-- local growth = aspect:GetGrowth()
	-- if growth > 0 then
	-- 	ui.SameLine( 0, 5 )
	-- 	ui.TextColored( 0, 0.5, 0, 1, loc.format( "({1#percent})", growth ))
	-- end

	local fatigue, threshold_name = puppet:GetStat( STAT.FATIGUE ):GetThreshold()
	if fatigue >= FATIGUE.TIRED then
	    ui.SameLine( 0, 15 )
		ui.TextColored( 1, 1, 0, 1, tostring(threshold_name))
	end
end

function GameScreen:RenderLocationDetails( ui, location, puppet )

	local w, h = location.map:GetExtents()
	local x, y = self.camera:WorldToScreen( 1, 0 )

	love.graphics.setFont( assets.FONTS.TITLE )
	love.graphics.print( location:GetTitle(), x, y )

	if puppet then
		if puppet:IsEnemy( location ) then
			love.graphics.setFont( assets.FONTS.SUBTITLE )
			self:SetColour( constants.colours.RED )
			love.graphics.print( "ENEMY", x, y - 16 )

		elseif puppet:IsAlly( location ) then
			love.graphics.setFont( assets.FONTS.SUBTITLE )
			self:SetColour( constants.colours.CYAN )
			love.graphics.print( "ALLY", x, y - 16 )
		end
	end
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

function GameScreen:RenderLocationTiles( location )
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

	-- Render map tile content
	for dx = 1, xtiles do
		for dy = ytiles, 1, -1 do
			local tx, ty = wx0 + dx - 1, wy0 + dy - 1
			local tile = location:GetTileAt( tx, ty )
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

	if self.puppet then
		if self.current_focus then
			local tx, ty = AccessCoordinate( self.current_focus )
			local x1, y1 = self.camera:WorldToScreen( tx, ty )
			local x2, y2 = self.camera:WorldToScreen( tx + 1, ty + 1 )
			local w, h = x2 - x1, y2 - y1

			love.graphics.setColor( 255, 255, 0, 255 )

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

function GameScreen:RenderDebugContextPanel( ui, panel, mx, my )
	local tile = self:ScreenToTile( mx, my )
	if tile then
		ui.TextColored( 0, 1, 1, 1, tostring(tile))

		if ui.MenuItem( "Teleport here", nil, nil, tile:IsPassable( self.puppet )) then
			self.puppet:WarpToTile( tile )
		end

		if ui.BeginMenu( "Spawn Carryable..." ) then
			local changed, filter_str = ui.InputText( "Filter", self.debug_filter or "", 128 )
			if changed then
				self.debug_filter = filter_str
			end
			recurse_subclasses( Object, function( class )
				if ui.MenuItem( class._classname ) then
					class():WarpToLocation( self.puppet:GetLocation(), tile:GetCoordinate() )
				end
			end )
			ui.EndMenu()
		end

		if ui.BeginMenu( "Advance Time..." ) then
			if ui.MenuItem( "Half Hour" ) then
				self.world:AdvanceTime( HALF_HOUR )
			end
			if ui.MenuItem( "One Hour" ) then
				self.world:AdvanceTime( HALF_HOUR )
			end
			if ui.MenuItem( "12 Hours" ) then
				self.world:AdvanceTime( HALF_DAY )
			end
			if ui.MenuItem( "24 Hours" ) then
				self.world:AdvanceTime( ONE_DAY )
			end
			ui.EndMenu()
		end

		ui.Separator()

		if ui.MenuItem( "Gen-Cursor here" ) then
			DBSET( "curs", self.puppet:GetLocation().map:CreateCursor( tile:GetCoordinate() ))
		end
	end
end


function GameScreen:RenderSenses( ui, agent )
	local now = self.world:GetDateTime()
	local senses = agent:GetSenses()
	if self.sense_log == nil then
		self.sense_log = {}
	else
		table.clear( self.sense_log )
	end

	local count = 0
	for i = #senses, 1, -1 do
		local sense = senses[i]
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
				table.insert( self.sense_log, r )
				table.insert( self.sense_log, g )
				table.insert( self.sense_log, b )
				table.insert( self.sense_log, a )
				table.insert( self.sense_log, tostring(sense.desc) )
			end

			count = count + 1
			if count > 5 then
				break
			end
		end
	end

	for i = #self.sense_log, 1, -5 do
		local r, g, b, a = self.sense_log[i-4], self.sense_log[i-3], self.sense_log[i-2], self.sense_log[i-1]
		local desc = self.sense_log[i]
		if self.show_msg_timestamps then
			desc = loc.format( "[{1}] {2}", Calendar.FormatTime( self.world:GetDateTime() ), desc )
		end
		ui.TextColored( r, g, b, a, desc )
	end

	if #self.sense_log > 0 and ui.Button( "*" ) then
		self.show_msg_timestamps = not self.show_msg_timestamps
	end
end

function GameScreen:ScreenToCell( mx, my )
	local wx, wy = self.camera:ScreenToWorld( mx, my )
	return math.floor( wx ), math.floor( wy )
end

function GameScreen:ScreenToTile( mx, my )
	local cx, cy = self:ScreenToCell( mx, my )
	if self.puppet and self.puppet:GetLocation() then
		return self.puppet:GetLocation():GetTileAt( cx, cy ), cx, cy
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
	if false and self.current_focus then
		local tx, ty = AccessCoordinate( self.current_focus )
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

function GameScreen:CycleFocus( tile )
	if not self.puppet or self.puppet:IsDead() then
		return
	end

	local location = self.puppet:GetLocation()
	local contents
	if tile then
		contents = {}
		for i, obj in tile:Contents() do
			if self.puppet:CanSee( obj ) then
				table.insert( contents, obj )
			end
		end
	else
		contents = self.puppet:GetVisibleObjectsByDistance()
	end
	-- table.arrayremove( contents, self.puppet )

	local idx = table.arrayfind( contents, self.current_focus ) or 0
	idx = (idx % #contents) + 1

	self:SetCurrentFocus( contents[ idx ] )
end

function GameScreen:CanFocus( obj )
	if self.puppet then
		local location = obj:GetLocation()
		if location ~= self.puppet:GetLocation() then
			return false
		end
		if not self.puppet:CanSee( obj ) then
			return false
		end
	end
	return true
end

function GameScreen:SetCurrentFocus( focus )
	if focus and not self:CanFocus( focus ) then
		focus = nil
	end

	self.current_focus = focus

	if self.verb_window == nil then
		self.verb_window = VerbMenu( self.world )
	end
	self.verb_window:RefreshContents( self.puppet, focus )

	-- Determine whether it needs to be shown.
	local verb_window = self:FindWindow( VerbMenu )
	if verb_window == nil and not self.verb_window:IsEmpty() then
		-- Show window.
		self:AddWindow( self.verb_window )

	elseif verb_window and self.verb_window:IsEmpty() then
		-- No verb: clear window.
		self:RemoveWindow( verb_window )
	end

	self:PanToCurrentInterest()
	-- print( "CURRENT FOCUS:", self.current_focus )
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
	for i = #self.windows, 1, -1 do
		local window = self.windows[i]
		if window.MousePressed and window:MousePressed( mx, my, btn ) then
			return true
		end
	end

	if self.hovered_tile then
		if Input.IsControl() then
			DBG(self.hovered_tile)
			return true

		elseif self.puppet and not self.puppet:IsDead() then
			if self.current_focus == self.hovered_tile then
				if self.hovered_tile:IsPassable( self.puppet ) then
					local verb = Verb.Travel( Waypoint( self.puppet:GetLocation(), self.hovered_tile:GetCoordinate() ))
					if verb:CanDo( self.puppet ) then
						self.puppet:DoVerbAsync( verb )
					end
				end
			else
				self:CycleFocus( self.hovered_tile )
			end
			return true
		end
	end

	return false
end

function GameScreen:KeyPressed( key )
	for i = #self.windows, 1, -1 do
		local window = self.windows[i]
		if window.KeyPressed and window:KeyPressed( key, self ) then
			return true
		end
	end

	local pan_delta = Input.IsShift() and 0.5 or 0.1

	if key == "space" then
		if self.world:IsPaused( PAUSE_TYPE.INTERRUPT ) then
			self.world:TogglePause( PAUSE_TYPE.INTERRUPT )
		else
			self.world:TogglePause( PAUSE_TYPE.DEBUG )
			-- self.is_panning = true
			-- self.pan_start_x, self.pan_start_y = self.camera:GetPosition()
			-- self.pan_start_mx, self.pan_start_my = love.mouse.getPosition()
		end

	elseif key == "i" then
		if self.inventory_window then
			self:RemoveWindow( self.inventory_window )
			self.inventory_window = nil
		else
			self.inventory_window = InventoryWindow( self.world, self.puppet, self.puppet:GetInventory() )
			self:AddWindow( self.inventory_window )
		end
		return true

	elseif key == "c" then
		local window = self:FindWindow( AgentDetailsWindow )
		if window then
			self:RemoveWindow( window )
		else
			self:AddWindow( AgentDetailsWindow( self.puppet, self.puppet ))
		end

	elseif key == "k" then
		local window = self:FindWindow( MemoryWindow )
		if window then
			self:RemoveWindow( window )
		else
			self:AddWindow( MemoryWindow( self.puppet ))
		end

	elseif key == "m" then
		local screen = MapScreen( self.world, self.puppet, self.last_location )
		GetGUI():AddScreen( screen )

	elseif key == "left" or key == "a" then
		if self.puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not self.puppet:IsBusy() and self.puppet:IsSpawned() then
			local verb = Verb.Walk( EXIT.WEST )
			if verb:CanDo( self.puppet ) then
				self.puppet:DoVerbAsync( verb )
			end
		end

	elseif key == "right" or key == "d" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() and puppet:IsSpawned() then
			local verb = Verb.Walk( EXIT.EAST )
			if verb:CanDo( puppet ) then
				puppet:DoVerbAsync( verb )
			end
		end

	elseif key == "up" or key == "w" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() and puppet:IsSpawned() then
			local verb = Verb.Walk( EXIT.SOUTH )
			if verb:CanDo( puppet ) then
				puppet:DoVerbAsync( verb )
			end
		end

	elseif key == "down" or key == "s" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() and puppet:IsSpawned() then
			local verb = Verb.Walk( EXIT.NORTH )
			if verb:CanDo( puppet ) then
				puppet:DoVerbAsync( verb )
			end
		end

	elseif key == "." then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() and puppet:IsSpawned() then
			if Input.IsShift() then
				puppet:AttemptVerb( Verb.LeaveLocation )
			else
				puppet:AttemptVerb( Verb.Wait, puppet )
			end
		end

	elseif key == "tab" then
		self:CycleFocus()

	elseif key == "escape" or key == "backspace" then
		self:SetCurrentFocus( nil )
	end

	-- elseif key == "=" then
	-- 	self.zoom_level = math.min( (self.zoom_level + 1), 3 )
	-- 	local mx, my = love.mouse.getPosition()
	-- 	self.camera:ZoomToLevel( self.zoom_level, mx, my )

	-- elseif key == "-" then
	-- 	self.zoom_level = math.max( (self.zoom_level - 1), -3 )
	-- 	local mx, my = love.mouse.getPosition()
	-- 	self.camera:ZoomToLevel( self.zoom_level, mx, my )

	return false
end

function GameScreen:KeyReleased( key )
	for i = #self.windows, 1, -1 do
		local window = self.windows[i]
		if window.KeyReleased and window:KeyReleased( key, self ) then
			return true
		end
	end

	if key == "space" then
		self.is_panning = false
		return true
	end
end
