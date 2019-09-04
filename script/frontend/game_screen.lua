local GameScreen = class( "GameScreen" )

function GameScreen:init()
	local gen = WorldGen()
	self.world = gen:GenerateWorld()
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

    ui.End()
end

function GameScreen:RenderObject( viewer, obj )
	local ui = imgui
    local flags = { "AlwaysAutoResize", "NoScrollBar", "NoClose"}

	ui.SetNextWindowSize( 400,300 )

	local name = loc.format( "{1.Id}", obj:LocTable( viewer ))
    ui.Begin( name, false, flags )

    if viewer:GetLocation() == obj:GetLocation() then
	    ui.Text( obj:GetShortDesc( viewer ))
	else
		ui.Text( loc.format( "{1.Id} is not with you.", obj:LocTable( viewer )))
	end

	-- self:RenderPotentialVerbs( ui, viewer, obj )
	if obj.RenderObject then
		obj:RenderObject( ui, viewer )
	end

	if viewer:GetFocus() == obj then
		if ui.Button( "Break Focus" ) then
			viewer:SetFocus( nil )
		end
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
    self:RenderAgentDetails( ui, puppet )

    puppet:CollectInteractions()

    -- Render what the player is doing...
    for i, verb in puppet:Verbs() do
    	ui.TextColored( 0.8, 0.8, 0, 1.0, "ACTING:" )
    	ui.SameLine( 0, 10 )
    	ui.Text( loc.format( "{1} ({2#percent})", verb:GetDesc(), verb:GetActingProgress() ))

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

	if puppet:GetFocus() then
		self:RenderObject( puppet, puppet:GetFocus() )
	end
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
    	i = i + 1
    end
end

function GameScreen:RenderLocationDetails( ui, location, agent )
	ui.Text( location:GetTitle() )
	ui.TextColored( 0.8, 0.8, 0.8, 1.0, location:GetDesc() )
	ui.Spacing()

	ui.Indent( 20 )

	-- Can only view location if not focussed on something else
	for i, obj in location:Contents() do
		ui.PushID(i)
		if agent ~= obj then
			ui.PushStyleColor( ui.Style_Text, 0, 1, 1, 1 )
			if is_instance( obj, Agent ) then
				local op = obj:GetOpinion( agent )
				if assets.OPINION_IMG[ op ] then
					ui.Image( assets.OPINION_IMG[ op ], 16, 16 )
					ui.SameLine( 0, 10 )
				end
			end

			local desc = loc.format( "* {1}", obj:GetShortDesc( agent ) )
			if agent:IsBusy() then
				ui.Text( desc )
			elseif ui.Selectable( desc, agent:GetFocus() == obj ) then
				agent:SetFocus( obj )
			end
			ui.PopStyleColor()

			if agent:GetFocus() == obj then
				ui.SameLine( 0, 10 )
				if ui.Text( "(Focus)" ) then
					agent:SetFocus( nil )
				end
			end
		end
		if DEV and Input.IsControl() and ui.IsItemClicked() then
			DBG( obj )
			break
		end

		ui.PopID()
	end

	ui.Unindent( 20 )
end

function GameScreen:RenderPotentialVerbs( ui, agent, obj )
	ui.Indent( 20 )

	local focus = agent:GetFocus()
	if focus ~= nil and focus == obj then
		if ui.Button( "0] Release Focus" ) then
			agent:SetFocus()
		end
	end

	for i, verb in agent:PotentialVerbs() do
		if verb.obj == obj or is_instance( verb, Verb.Travel) then
			local ok, details = verb:CanInteract()
			local txt = loc.format( "{1}] {2}", i, verb:GetRoomDesc() )

			if not ok or agent:IsBusy() then
				ui.TextColored( 0.5, 0.5, 0.5, 1, txt )
			else
				if verb.COLOUR then
					ui.PushStyleColor( ui.Style_Text, Colour4( verb.COLOUR) )
				else
					ui.PushStyleColor( ui.Style_Text, 1, 1, 0, 1 )
				end

				if ui.Selectable( txt ) then
					verb:BeginActing()
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

	else
		-- Render the background image
	    if agent:GetLocation():GetImage() then
		    -- love.graphics.rectangle( "fill", 0, h, W, H * 0.75 - h )
		    love.graphics.draw( agent:GetLocation():GetImage(), 0, h )
		end
	end
end

function GameScreen:GetDebugEnv( env )
	env.player = self.world:GetPlayer()
end

function GameScreen:RenderSenses( ui, agent )
	for i, txt in agent:Senses() do
		ui.Text( txt )
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
	elseif key == "f" then
		self.world:GetPuppet():SetFocus()
	end

	return false
end

function GameScreen:KeyReleased( key )
end

return GameScreen
