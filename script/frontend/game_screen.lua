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

    -- Render what the player is doing...
    for i, verb in puppet:Verbs() do
    	ui.TextColored( 0.8, 0.8, 0, 1.0, "ACTING:" )
    	ui.SameLine( 0, 10 )
    	ui.Text( loc.format( "{1} ({2#percent})", tostring(verb), verb:GetActingProgress() ))
    end
    ui.Separator()

    -- Render the things at the player's location.
    self:RenderLocationDetails( ui, puppet:GetLocation(), puppet )

    self:RenderBackground( ui, puppet )

    ui.End()

    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove" }
	ui.SetNextWindowSize( love.graphics.getWidth(), love.graphics.getHeight() * 0.25 )
	ui.SetNextWindowPos( 0, love.graphics.getHeight() * 0.75 )

    ui.Begin( "OUTPUT", true, flags )
    self:RenderSenses( ui, puppet )
    self:RenderAgentFocus( ui, puppet )
	ui.SetScrollHere()
    ui.End()
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
    	ui.Text( loc.format( "{1}: {2}", stat, aspect:GetValue() ))
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

			local desc = loc.format( "* {1}", obj:GetShortDesc() )
			if agent:IsBusy() then
				ui.Text( desc )
			elseif ui.Selectable( desc, agent:GetFocus() == obj ) then
				agent:SetFocus( obj )
			end
			ui.PopStyleColor()

			if agent:GetFocus() == obj then
				ui.SameLine( 0, 10 )
				ui.Text( "(Focus)" )
			end
		end
		if DEV and Input.IsControl() and ui.IsItemClicked() then
			DBG( obj )
			break
		end

		ui.PopID()
	end
	ui.Unindent( 20 )

	if agent then
		ui.Indent( 20 )
		self:RenderLocationInteractions( ui, agent )
		ui.Unindent( 20 )
	end
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

function GameScreen:RenderLocationInteractions( ui, agent )
	local t = agent:CollectInteractions( nil, {} )
	for i, verb in ipairs( t ) do
		local ok, details = verb:CanInteract( agent, nil )
		if verb.COLOUR then
			ui.PushStyleColor( ui.Style_Text, Colour4( verb.COLOUR) )
		else
			ui.PushStyleColor( ui.Style_Text, 1, 1, 0, 1 )
		end

		local desc = verb:GetRoomDesc()
		if agent:IsBusy() then
			ui.TextColored( 0.5, 0.5, 0.5, 1, desc )
		elseif ui.Selectable( desc ) then
			verb:BeginActing( agent )
		end
		ui.PopStyleColor()
	end
end

function GameScreen:GetDebugEnv( env )
	env.player = self.world:GetPlayer()
end

function GameScreen:RenderAgentFocus( ui, agent )
	local focus = agent:GetFocus()
	if focus == nil then
		return
	end

	local t = agent:CollectInteractions( focus, {} )
	for i, verb in ipairs( t ) do
		if i > 1 then
			ui.SameLine( 0, 5 )
		end
		local ok, details = verb:CanInteract( agent, focus )
		if not ok then
			ui.TextColored( 0.5, 0.5, 0.5, 1, verb:GetDesc() )
		else
			local txt = loc.format( "{1} [{2}]", verb:GetDesc( focus ), verb:GetDC() )
			if ui.Button( txt ) then
				verb:BeginActing( agent, agent:GetFocus() )
			end
		end

		if ui.IsItemHovered() and details then
			ui.SetTooltip( details )
		end
	end

	ui.SameLine( 0, 5 )
	if ui.Button( "Release focus" ) then
		agent:SetFocus()
	end
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
	return false
end

function GameScreen:KeyReleased( key )
end

return GameScreen
