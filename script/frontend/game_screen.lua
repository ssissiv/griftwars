local GameScreen = class( "GameScreen", RenderScreen )

function GameScreen:init( world )
	assert( is_instance( world, World ))
	RenderScreen.init( self )
	
	self.world = world
    world:Start()
	self.nexus = WorldNexus( self.world, self )
	self.world:SetNexus( self.nexus )
	self.world:ListenForAny( self, self.OnWorldEvent )

	-- List of objects and vergbs in the currently rendered location.
	self.objects = {}

	-- List of window panels.
	self.windows = {}
	self.floaters = {}

	self.zoom_level = 0.5
	self.camera = Camera()
	self.camera:SetViewPort( 0, 0, GetGUI():GetSize() )
	self.camera:ZoomToLevel( self.zoom_level )
	self:PanToCurrentInterest()

	self:OnPuppetChanged( self.world:GetPuppet() )

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
	self:PostMessage( "Saved!", constants.colours.GREEN )
end

function GameScreen:LoadWorld( filename )
	assert( filename )
	self:PostMessage( loc.format( "Loading from {1}", filename ), constants.colours.GREEN )
	local world = DeserializeFromFile( filename )
	GetGUI():AddScreen( GameScreen( world ))
end

function GameScreen:PostMessage( msg, color )
	print( msg )
	self.post_msg = msg
	self.post_color = color or constants.colours.WHITE
	self.post_time = love.timer.getTime()
end

function GameScreen:ClearMessage()
	self.post_msg = nil
	self.post_color = nil
	self.post_time = nil
end

function GameScreen:OnUpdateScreen( dt )
	self.world:UpdateWorld( dt )

	self:UpdateFloaters( dt )

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
			screen:GenerateMapMarkers()
		end

	elseif event_name == ENTITY_EVENT.TILE_CHANGED then
		-- if not self.lock_focus then
		-- 	self:SetCurrentFocus( nil )
		-- else
			if self.verb_window then
				self.verb_window:RefreshContents( self.puppet, self.current_focus )
			end
		-- end
		self:PanToCurrentInterest()

	elseif event_name == AGENT_EVENT.INTENT_CHANGED then
		if self.verb_window then
			self.verb_window:RefreshContents( self.puppet, self.current_focus )
		end

	elseif event_name == ENTITY_EVENT.STAT_CHANGED then
		local stat, new_value, old_value, aspect = ...
		if stat == STAT.HEALTH then
			if new_value < old_value then
				self:AddDamageFloater( old_value - new_value, aspect.owner )
			else
				self:AddHealFloater( new_value - old_value, aspect.owner )
			end
		end

	elseif event_name == AGENT_EVENT.DIED then
		self:SetCurrentFocus( nil )
	end
end

function GameScreen:RenderStatusEffects( ui, agent )
	ui.PushID( "StatusEffects"..rawstring(agent) )

	local effects = 0
	for i, aspect in agent:Aspects() do
		if is_instance( aspect, Aspect.StatusEffect ) then
			if effects > 0 then
				ui.SameLine( 0, 5 )
			end
			local txt = aspect:GetDesc( agent )
			ui.Button( txt )
			effects = effects + 1
			if ui.IsItemHovered() then
				ui.BeginTooltip()
				aspect:RenderDebugPanel( ui )
				ui.EndTooltip()
			end
		end
	end

	ui.PopID()
end

function GameScreen:RenderCombatTargetDetails( ui, puppet, target )
	-- Name, health
	local hp, max_hp = target:GetHealth()
	local txt = loc.format( "{1.Id} - {2}/{3}", target:LocTable( self.puppet ), hp, max_hp )
	if self.current_focus == target then
		ui.TextColored( 1.0, 0.1, 0.1, 1.0, txt )
	else
		ui.TextColored( 0.5, 0, 0, 1.0, txt )
	end

	-- Attack power
	ui.SameLine( 0 )
	local ap, details = target:CalculateAttackPower()
	ui.TextColored( 0, 1, 1, 1, loc.format( "AP: {1}", ap ))
	local show_tt = ui.IsItemHovered()
	if show_tt and details then
		ui.SetTooltip( details )
	end

	local verb_desc
	for i, verb in target:Verbs() do
        while verb do
            local desc = verb:GetDesc( puppet )
            if desc then
            	if verb_desc then
					local time_left = verb:GetActingTime()
					if time_left then
						verb_desc = loc.format( "{1}, {2} ({3#duration})", verb_desc, desc, time_left )
					end
                else
                	verb_desc = desc
                end
            end
            verb = verb.child
        end
    end
    if verb_desc then
    	ui.SameLine( 200 )
    	ui.Text( verb_desc )
    end


-- 	local attack = target:GetAspect( Verb.Combat ):GetCurrentAttack()
-- 	if attack then
-- 		local t = attack:GetActingProgress()
-- 		if t then
-- 			ui.SameLine( 0, 50 )
-- 			local time_left, total_time = attack:GetActingTime()
-- 			ui.Text( loc.format( "{1} {2%.2d} ({3})", attack:GetDesc(),
-- 				t, Calendar.FormatDuration( total_time )) )
-- 			ui.SameLine( 0, 50 )

	  --   	local damage, details = attack:CalculateDamage( attack:GetTarget() )
-- 			ui.Text( loc.format( "{1} damage", damage ))

			-- if details and ui.IsItemHovered() then
	  --   		ui.SetTooltip( details )
-- 			end
-- 		end
-- 	end

	ui.SameLine( 0 )
	self:RenderStatusEffects( ui, target )
	ui.Dummy( 0, 0 )
end

function GameScreen:RenderCombatDetails( ui, puppet )
    local combat = puppet:GetAspect( Verb.Combat )
    if combat and puppet:InCombat() then
    	ui.Separator()

    	-- Allies.
		local hp, max_hp = puppet:GetHealth()
		ui.TextColored( 0, 1, 0, 1, loc.format( "{1.Id} - {2}/{3}",
			puppet:LocTable( self.puppet ), hp, max_hp ))

		ui.SameLine( 0, 50 )
    	local wpn = puppet:GetWeapon()
    	local damage, details = puppet:CalculateAttackPower()
    	ui.Text( loc.format( "AP: {1} ({2})", damage, wpn and wpn:GetName( puppet ) or "Unarmed" ))
    	local show_tt = ui.IsItemHovered()
    	if show_tt and details then
    		ui.SetTooltip( details )
    	end
    end
end

function GameScreen:RenderLocationContentDetails( ui, puppet )
	for i, obj in puppet:GetLocation():Contents() do
		if obj == puppet then
			--
		elseif is_instance( obj, Agent ) then
			if obj:InCombat() then
				self:RenderCombatTargetDetails( ui, puppet, obj )

			elseif obj:HasAspect( StatusEffect.RecentNoise ) then
				local alertness = obj:CalculateAlertness()
				local hp, max_hp = obj:GetHealth()
				local txt = loc.format( "{1.Id} - {2}/{3}", obj:LocTable( self.puppet ), hp, max_hp )
				ui.TextColored( 0.5, 0.5, 0, 1.0, txt )

				ui.SameLine( 0, 10 )
				ui.Text( loc.format( "Alertness: {1}", alertness ))
			end
		end
	end
end

function GameScreen:OnRenderScreen( gui )

	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove", "NoScrollBar", "NoBringToFrontOnFocus" }
	-- ui.SetNextWindowSize( love.graphics.getWidth(), 200 )
	ui.SetNextWindowPos( 0, 0 )

    ui.Begin( "ROOM", true, flags )

    ui.Dummy( love.graphics.getWidth(), 0 )

    -- Render details about the player.
    local puppet = self.world:GetPuppet()
    local use_seconds = self.world:CalculateTimeElapsed( 1.0 ) < 1/60 or (puppet and puppet:InCombat())
    local timestr = Calendar.FormatDateTime( self.world:GetDateTime(), use_seconds )
    ui.Text( timestr )
    if self.world:IsPaused() then
    	ui.SameLine( 0, 10 )
    	ui.Text( loc.format( "(PAUSED - {1})", table.concat( self.world.pause, " " ) ))

    	if self.world:IsPaused( PAUSE_TYPE.ERROR ) then
    		ui.SameLine( 0, 10 )
    		if ui.Button( "Resume error" ) then
				self.world:TogglePause( PAUSE_TYPE.ERROR )
			end
		end
    end

    local dt = self.world:CalculateTimeElapsed( 1.0 )
    if dt ~= WALL_TO_GAME_TIME then
    	ui.SameLine( 0, 10 )
    	ui.Text( string.format( "(x%.2f)", dt / WALL_TO_GAME_TIME))
    end

    -- Posted message.
    if self.post_msg then
    	ui.SameLine( 0, 20 )
    	local MSG_DURATION = 5.0
    	local now = love.timer.getTime()
    	local t = 1.0 - clamp( (now - self.post_time) / MSG_DURATION, 0, 1.0 )
    	local r, g, b, a = Colour4( self.post_color, t )
    	ui.TextColored( r, g, b, a, self.post_msg )
    	if t >= 1.0 then
    		self:ClearMessage()
    	end
    end

    -- Render what the player is doing...
    if puppet then
	    for i, verb in puppet:Verbs() do
			ui.SameLine( 0, 10 )
	    	ui.TextColored( 0.8, 0.8, 0, 1.0, "ACTING:" )
	    	ui.SameLine( 0, 10 )
	    	ui.Text( loc.format( "{1} ({2#percent})", verb:GetDesc( puppet ) or tostring(verb), verb:GetActingProgress() or 1.0 ))

	    	if verb:CanCancel() then
	    		ui.SameLine( 0, 10 )
	    		if ui.Button( "Cancel" ) then
	    			puppet:Echo( "Nah, forget that." )
	    			verb:Cancel( "player cancel" )
	    		end
	    	end
	    end

	    -- Show last verb executed
	    local last_verb = puppet:GetLastVerb()
	    if last_verb and last_verb:GetDurationTook() then
		    ui.SameLine( 0, 15 )
		    ui.Text( loc.format( "({1} took {2#duration})", last_verb:GetActDesc( puppet ), last_verb:GetDurationTook() ))
		end

		ui.Separator()

	  	self:RenderAgentDetails( ui, puppet )

	    self:RenderLocationContentDetails( ui, puppet )
	    ui.Separator()

	    self:RenderSenses( ui, puppet )		
	end
	ui.SetScrollHere()

	self.top_height = ui.GetWindowHeight() 
    ui.End()

   	-- render map --

    local location = puppet and puppet:GetLocation() or self.last_location
    if location then
	    -- Render the things at the player's location.
	    self:RenderLocationTiles( location, puppet )

	    self:RenderLocationDetails( ui, location )

	    self:RenderFloaters()

	    self.last_location = location
	end

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

function GameScreen:AddFloater( floater )
	table.insert( self.floaters, floater )
end

function GameScreen:AddTileFloater( txt, tile )
	local floater = Floater( txt )
	floater:SetCoordinate( tile:GetCoordinate() )
	floater:SetColour( 0xFFFFFFFF )
	self:AddFloater( floater )
end

function GameScreen:AddDamageFloater( damage, agent )
	local floater = Floater( tostring(damage) )
	floater:SetCoordinate( agent:GetCoordinate() )
	floater:SetColour( 0xFF0000FF )
	self:AddFloater( floater )
end

function GameScreen:AddHealFloater( amount, agent )
	local floater = Floater( tostring(amount) )
	floater:SetCoordinate( agent:GetCoordinate() )
	floater:SetColour( 0x00FF00FF )
	self:AddFloater( floater )
end

function GameScreen:UpdateFloaters( dt )
	for i = #self.floaters, 1, -1 do
		if not self.floaters[i]:UpdateFloater( dt ) then
			table.remove( self.floaters, i )
		end
	end
end

function GameScreen:RenderFloaters()
	for i, floater in ipairs( self.floaters ) do
		floater:RenderFloater( self )
	end
end

function GameScreen:RenderAgentDetails( ui, puppet )
    ui.TextColored( 0.5, 1.0, 1.0, 1.0, loc.format( "{1}", puppet ))
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

    ui.SameLine( 0, 15 )
    ui.TextColored( 1, 1, 0, 1, loc.format( "FATIGUE: {1}/{2}", puppet:GetFatigue() ))

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

	self:RenderStatusEffects( ui, puppet )

    -- Intent buttons.
	local aspect = puppet:GetAspect( Aspect.Puppet )
    for i, bitname in pairs( INTENT_ARRAY ) do
    	local bits = aspect:GetIntent()
    	if CheckBits( bits, INTENT[ bitname ] ) then
    		ui.PushStyleColor( "Button", 1, 0, 0, 1 )
    	end

    	if i > 1 then
    		ui.SameLine( 0, 10 )
    	end
    	if ui.Button( INTENT_NAME[ bitname ] ) then
    		aspect:SetIntent( ToggleBits( bits, INTENT[ bitname ] ))
    	end

    	if CheckBits( bits, INTENT[ bitname ] ) then
    		ui.PopStyleColor()
    	end
    end
end

function GameScreen:RenderLocationDetails( ui, location, puppet )

	local x1, y1, x2, y2 = location.map:GetExtents()
	local x, y = self.camera:WorldToScreen( x1, y1 - 1 )
	local faction = location:GetAspect( Aspect.FactionMember )

	love.graphics.setFont( assets.FONTS.TITLE )
	love.graphics.print( location:GetTitle(), x, y )

	local subtitle = ""
	if faction then
		subtitle = faction:GetName()
	end

	if puppet and puppet:IsEnemy( location ) then
		self:SetColour( constants.colours.RED )
		subtitle = subtitle .. "(ENEMY)"

	elseif puppet and puppet:IsAlly( location ) then
		self:SetColour( constants.colours.CYAN )
		subtitle = subtitle .. "(ALLY)"

	elseif #subtitle > 0 then
		self:SetColour( constants.colours.LT_GRAY )
	end

	if #subtitle > 0 then
		love.graphics.setFont( assets.FONTS.SUBTITLE )
		love.graphics.print( subtitle, x, y - 16 )
	end
end

function GameScreen:RenderLocationTiles( location )
	local W, H = GetGUI():GetSize()

	local wx0, wy0 = self.camera:ScreenToWorld( 0, self.top_height )
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

		if ui.BeginMenu( "Spawn Agent..." ) then
			local changed, filter_str = ui.InputText( "Filter", self.debug_filter or "", 128 )
			if changed then
				self.debug_filter = filter_str
			end
			recurse_subclasses( Agent, function( class )
				if self.debug_filter == nil or class._classname:lower():find( self.debug_filter ) then
					if ui.MenuItem( class._classname ) then
						class():WarpToLocation( self.puppet:GetLocation(), tile:GetCoordinate() )
					end
				end
			end )
			ui.EndMenu()			
		end

		if ui.BeginMenu( "Spawn Carryable..." ) then
			local changed, filter_str = ui.InputText( "Filter", self.debug_filter or "", 128 )
			if changed then
				self.debug_filter = filter_str
			end
			recurse_subclasses( Object, function( class )
				if self.debug_filter == nil or class._classname:lower():find( self.debug_filter ) then
					if ui.MenuItem( class._classname ) then
						class():WarpToLocation( self.puppet:GetLocation(), tile:GetCoordinate() )
					end
				end
			end )
			ui.EndMenu()
		end

		ui.Separator()

		for i, obj in tile:Contents() do
			if is_instance( obj, Agent ) and not obj:IsDead() then
				if ui.MenuItem( loc.format( "Kill {1}", obj )) then
					obj:Kill()
				end
			end
		end
		
		if ui.MenuItem( "Gen-Cursor here" ) then
			DBSET( "curs", self.puppet:GetLocation().map:CreateCursor( tile:GetCoordinate() ))
		end
		
		if ui.BeginMenu( "Advance Time..." ) then
			if ui.MenuItem( "15 mins" ) then
				self.world:AdvanceTime( 0.5 * HALF_HOUR )
			end
			if ui.MenuItem( "Half Hour" ) then
				self.world:AdvanceTime( HALF_HOUR )
			end
			if ui.MenuItem( "One Hour" ) then
				self.world:AdvanceTime( ONE_HOUR )
			end
			if ui.MenuItem( "6 Hours" ) then
				self.world:AdvanceTime( 6 * ONE_HOUR )
			end
			if ui.MenuItem( "12 Hours" ) then
				self.world:AdvanceTime( HALF_DAY )
			end
			if ui.MenuItem( "24 Hours" ) then
				self.world:AdvanceTime( ONE_DAY )
			end
			ui.EndMenu()
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
		return self.puppet:GetLocation():LookupTile( cx, cy ), cx, cy
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

function GameScreen:GetCurrentFocus()
	return self.current_focus
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

	if self.current_focus and (self.world:IsPaused( PAUSE_TYPE.DEBUG ) or self.world:IsPaused( PAUSE_TYPE.ERROR )) then
		if self.last_panel then
			GetDbg():ClearPanel( self.last_panel )
		end

		self.last_panel = DBG( self.current_focus )
	end
	-- print( "CURRENT FOCUS:", self.current_focus )
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

function GameScreen:MousePressed( mx, my, btn, double_click )
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
			if double_click and self.hovered_tile and self.hovered_tile:IsPassable( self.puppet ) then
				local wp = Waypoint( self.puppet:GetLocation(), self.hovered_tile:GetCoordinate() )
				local verb = Verb.Travel( self.puppet, wp )
				self.puppet:AttemptVerb( verb )
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

	if key == "i" then
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

	elseif key == "h" then
		if self.puppet then
			local aspect = self.puppet:GetAspect( Aspect.Puppet )
			aspect:ToggleIntent( INTENT.HOSTILE )
		end

	elseif key == "l" then
		if self.puppet then
			local aspect = self.puppet:GetAspect( Aspect.Puppet )
			aspect:ToggleIntent( INTENT.STEALTH )
		end

	elseif key == "y" then
		if self.puppet then
			local aspect = self.puppet:GetAspect( Aspect.Puppet )
			aspect:ToggleIntent( INTENT.DIPLOMACY )
		end

	elseif key == "m" then
		local screen = MapScreen( self.world, self.puppet )
		GetGUI():AddScreen( screen )

	elseif key == "left" or key == "a" then
		if self.puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not self.puppet:IsBusy() and self.puppet:IsSpawned() then
			self.puppet:AttemptVerb( Verb.Walk( self.puppet, DIR.W ))
		end

	elseif key == "right" or key == "d" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() and puppet:IsSpawned() then
			self.puppet:AttemptVerb( Verb.Walk( self.puppet, DIR.E ))
		end

	elseif key == "up" or key == "w" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() and puppet:IsSpawned() then
			self.puppet:AttemptVerb( Verb.Walk( self.puppet, DIR.S ))
		end

	elseif key == "down" or key == "s" then
		local puppet = self.world:GetPuppet()
		if puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and not puppet:IsBusy() and puppet:IsSpawned() then
			self.puppet:AttemptVerb( Verb.Walk( self.puppet, DIR.N ))
		end

	elseif key == "space" then

		if Input.IsControl() then
			if self.world:IsPaused( PAUSE_TYPE.INTERRUPT ) then
				self.world:TogglePause( PAUSE_TYPE.INTERRUPT )
			else
				self.world:TogglePause( PAUSE_TYPE.DEBUG )
				-- self.is_panning = true
				-- self.pan_start_x, self.pan_start_y = self.camera:GetPosition()
				-- self.pan_start_mx, self.pan_start_my = love.mouse.getPosition()
			end

		elseif self.puppet and not self.world:IsPaused( PAUSE_TYPE.NEXUS ) and self.puppet:IsSpawned() then
			local wait = self.puppet:FindVerb( Verb.Wait )
			if wait then
				wait:Cancel()
			elseif not self.puppet:IsBusy() then
				self.puppet:AttemptVerb( Verb.Wait, self.puppet )
			end
		end

	elseif key == "return" or key == "enter" then
		if self.puppet then
			-- Is there a portal to activate?
			for i, obj in self.puppet:GetTile():Contents() do
				local portal = obj:GetAspect( Aspect.Portal )
				if portal and portal:GetDest() then
					local ok, reason = self.puppet:DoVerbAsync( Verb.UsePortal( self.puppet, portal ))
					if not ok then
						Msg:EchoTo( self.puppet, reason )
					end
					break
				end
			end
		end

	elseif key == "tab" then
		self:CycleFocus()

	elseif key == "escape" or key == "backspace" then
		self:SetCurrentFocus( nil )

	elseif key == "=" then
		self.zoom_level = math.min( (self.zoom_level + 1), 3 )
		local mx, my = love.mouse.getPosition()
		if self.puppet then
			mx, my = self.camera:WorldToScreen( self.puppet:GetCoordinate() )
		end
		self.camera:ZoomToLevel( self.zoom_level, mx, my )

	elseif key == "-" then
		self.zoom_level = math.max( (self.zoom_level - 1), -3 )
		local mx, my = love.mouse.getPosition()
		if self.puppet then
			mx, my = self.camera:WorldToScreen( self.puppet:GetCoordinate() )
		end
		self.camera:ZoomToLevel( self.zoom_level, mx, my )
	end

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
