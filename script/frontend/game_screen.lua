local GameScreen = class( "GameScreen" )

function GameScreen:init()
	local gen = WorldGen()
	self.world = gen:GenerateWorld()
	self.nexus = WorldNexus( self.world, self )
	self.world:SetNexus( self.nexus )
	self.world:Start()

	-- List of objects and vergbs in the currently rendered location.
	self.objects = {}
	self.verbs = {}

	-- List of window panels.
	self.windows = {}

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
end

function GameScreen:RenderDebug()
	imgui.Text( string.format( "Debug" ))
end

function GameScreen:RenderInventory( puppet )
	local ui = imgui
    local flags = { "AlwaysAutoResize", "NoScrollBar" }

	ui.SetNextWindowSize( 400,300 )

    ui.Begin( "Inventory", false, flags )

    local player = puppet:GetPlayer()
	if player and ui.TreeNodeEx( "Dice", "DefaultOpen" ) then
		for i, die in ipairs( player:GetDice() ) do
			die:RenderObject( ui, puppet )
		end
		ui.TreePop()
	end

    local rumours = puppet:GetAspect( Skill.RumourMonger )
    if rumours and ui.TreeNodeEx( "Knowledge", "DefaultOpen" ) then
    	for e_info, count in rumours:Info() do
    		local txt = loc.format( "{1}: {2}", e_info, count )
    		if ui.Button( txt ) then
    		end
    	end

		ui.TreePop()
	end

	for i, obj in puppet:GetInventory():Items() do 
		ui.Selectable( tostring(obj) )
	end

    ui.End()
end

function GameScreen:RenderScreen( gui )

	local ui = imgui
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove", "NoScrollBar", "NoBringToFrontOnFocus" }
	ui.SetNextWindowSize( love.graphics.getWidth(), 200 )
	ui.SetNextWindowPos( 0, 0 )

    ui.Begin( "ROOM", true, flags )
    local puppet = self.world:GetPuppet()

    -- Render details about the player.
    ui.Text( Calendar.FormatTime( self.world:GetDateTime() ))
    if self.world:IsPaused() then
    	ui.SameLine( 0, 10 )
    	ui.Text( "(PAUSED)" )
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

    self:RenderPotentialVerbs( ui, puppet )

    self:RenderBackground( ui, puppet )

    ui.End()

    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove" }
	ui.SetNextWindowSize( love.graphics.getWidth(), love.graphics.getHeight() * 0.25 )
	ui.SetNextWindowPos( 0, love.graphics.getHeight() * 0.75 )

    ui.Begin( "OUTPUT", true, flags )
	    self:RenderSenses( ui, puppet )
	ui.SetScrollHere()
    ui.End()

	if self.show_inventory then
		self:RenderInventory( puppet )
	end

	for i, window in ipairs( self.windows ) do
		window:RenderImGuiWindow( ui, self )
	end
end

function GameScreen:AddWindow( window )
	table.insert( self.windows, window )
end

function GameScreen:RemoveWindow( window )
	table.arrayremove( self.windows, window )
end

function GameScreen:RenderAgentDetails( ui, puppet )
    ui.TextColored( 0.5, 1.0, 1.0, 1.0, puppet:GetName() )
    ui.SameLine( 0, 20 )
    ui.Text( "HP: 3/3" )

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

    local tokens = puppet:GetAspect( Aspect.TokenHolder )
    if tokens then
    	local count, max_count = tokens:GetTokenCount()
    	for i = 1, max_count do
	    	ui.SameLine( 0, 15 )
	    	local token = tokens:GetTokenAt( i )
	    	if token then
	    		ui.Text( "[" )
	   			ui.SameLine( 0, 5 )
	   			if token:IsCommitted() then
			    	ui.TextColored( 0.4, 0.4, 0.4, 1.0, tostring(token) )
			    	if ui.IsItemHovered() then
			    		if type(token.committed) == "table" then
				    		ui.SetTooltip( loc.format( "{1} ({2})", tostring(token.committed), Agent.GetAgentOwner( token.committed )))
				    	else
				    		ui.SetTooltip( tostring(token.committed) )
				    	end
			    	end
	   			else
			    	ui.TextColored( 0.7, 0.7, 0.2, 1.0, tostring(token) )
			    end
	   			ui.SameLine( 0, 5 )
	    		ui.Text( "]" )
		    else
		    	ui.Text( "[ ]" )
		    end
	    end
	end
end

function GameScreen:RenderLocationDetails( ui, location, agent )
	ui.Text( location:GetTitle() )
	ui.TextColored( 0.8, 0.8, 0.8, 1.0, location:GetDesc() )
	ui.Spacing()

	ui.Indent( 20 )

	table.clear( self.objects )

	-- Can only view location if not focussed on something else
	local count = 0
	for i, obj in location:Contents() do
		ui.PushID(i)
		if agent ~= obj then
			count = count + 1
			self.objects[ count ] = obj

			ui.PushStyleColor( ui.Style_Text, 0, 1, 1, 1 )
			if is_instance( obj, Agent ) then
				local op = obj:GetOpinion( agent )
				if assets.OPINION_IMG[ op ] then
					ui.Image( assets.OPINION_IMG[ op ], 16, 16 )
					ui.SameLine( 0, 10 )
				end
			end

			local desc = loc.format( "{1}) {2}", string.char( count + 96 ), obj:GetShortDesc( agent ) )
			if agent:IsBusy() then
				ui.Text( desc )
			elseif ui.Selectable( desc, agent:GetFocus() == obj ) then
				agent:SetFocus( obj )
			end
			ui.PopStyleColor()
	
			if DEV and Input.IsControl() and ui.IsItemClicked() then
				DBG( obj )
				break
			end

			if agent:GetFocus() == obj then
				ui.SameLine( 0, 10 )
				if ui.Text( "(Focus)" ) then
					agent:SetFocus( nil )
				end

				if agent:IsPlayer() then
					ui.Indent( 20 )
					-- Make a verb.
					local count, count_potential = 0, 0
					for i, aspect in obj:Aspects() do
						if is_instance( aspect, Interaction ) then
							count = count + 1
							-- if aspect:IsSatisfied( agent ) then
								local ok, reason = true
								if aspect.CanInteract then
									ok, reason = aspect:CanInteract( agent )
								end
								if ok or reason then
									if not ok then
										ui.PushStyleColor( "Button", 0.2, 0.2, 0.2, 1 )
									end
									if ui.Button( aspect._classname ) and ok then
										aspect:SatisfyReqs( agent )
									end
									if not ok then
										ui.PopStyleColor()
									end
									if ui.IsItemHovered() then
										ui.BeginTooltip()
										local tt = aspect:GetToolTip()
										if tt then
											ui.Text( tostring(tt) )
										end
										if reason then
											ui.TextColored( 1, 0, 0, 1, tostring(reason))
										end

										ui.EndTooltip()
									end
								end
							-- end
						end
					end
					ui.Unindent( 20 )
				end
			end
		end

		ui.PopID()
	end

	ui.Unindent( 20 )
end

function GameScreen:RenderPotentialVerbs( ui, agent, obj )
	ui.Indent( 20 )

	if self.verbs == nil then
		self.verbs = {}
	else
		table.clear( self.verbs )
	end

	for i, verb in agent:PotentialVerbs() do
		if verb.obj == obj or is_instance( verb, Verb.LeaveLocation) then
			local ok, details = verb:CanInteract()
			local txt = loc.format( "{1}] {2}", i, verb:GetRoomDesc() )
			self.verbs[i] = verb

			if not ok or agent:IsBusy() or self.world:IsPaused() then
				ui.TextColored( 0.5, 0.5, 0.5, 1, txt )
			else
				if verb.COLOUR then
					ui.PushStyleColor( "Text", Colour4( verb.COLOUR) )
				else
					ui.PushStyleColor( "Text", 1, 1, 0, 1 )
				end

				if ui.Selectable( txt ) then
					agent:DoVerb( verb )
				end

				ui.PopStyleColor()
			end

			if ui.IsItemHovered() and details then
				ui.SetTooltip( details )
			end
		end
	end

	ui.Unindent( 20 )
end

function GameScreen:RenderBackground( ui, agent )
    local _, h = ui:GetWindowSize()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor( 255, 255, 255 )

	-- Render the background image
    if agent:GetLocation():GetImage() then
	    -- love.graphics.rectangle( "fill", 0, h, W, H * 0.75 - h )
	    love.graphics.draw( agent:GetLocation():GetImage(), 0, h )
	end

	if is_instance( agent:GetFocus(), Agent ) then
		-- head
	    love.graphics.setColor( table.unpack( agent.viz.skin_colour ))
		love.graphics.circle( "fill", W/2, h + 150, 100 )

		-- eyes
		love.graphics.setColor( 0, 0, 0 )
		love.graphics.circle( "line", W/2 - 30, h + 150 - 20, 20 )
		love.graphics.circle( "line", W/2 + 30, h + 150 - 20, 20 )

		-- pupils
		love.graphics.setColor( 0, 60, 90 )
		love.graphics.circle( "fill", W/2 - 30, h + 150 - 10, 10 )
		love.graphics.circle( "fill", W/2 + 30, h + 150 - 10, 10 )
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

function GameScreen:MouseMoved( mx, my )
	if love.keyboard.isDown( "space" ) then
	end
end

function GameScreen:MousePressed( mx, my, btn )
	return false
end

function GameScreen:KeyPressed( key )
	if key == "i" then
		self.show_inventory = not self.show_inventory
		return true
	elseif key == "f" then
		self.world:GetPuppet():SetFocus()
		return true
	elseif tonumber(key) then
		local verb = self.verbs[ tonumber(key) ]
		if verb then
			local ok, details = verb:CanInteract()
			if ok and not self.world:IsPaused() then
				self.world:GetPuppet():DoVerb( verb )
			end
		end
		return true
	else
		local obj_idx = string.byte(key) - 97 + 1
		local obj = self.objects[ obj_idx ]
		if obj then
			if self.world:GetPuppet():GetFocus() == obj then
				self.world:GetPuppet():SetFocus( nil )
			else
				self.world:GetPuppet():SetFocus( obj )
			end
		end
	end

	return false
end

function GameScreen:KeyReleased( key )
end

return GameScreen
