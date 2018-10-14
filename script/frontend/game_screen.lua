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
    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove", "NoScrollBar" }
	ui.SetNextWindowSize( love.graphics.getWidth(), love.graphics.getHeight() * 0.7 )
	ui.SetNextWindowPos( 0, 0 )

    ui.Begin( "ROOM", true, flags )
    local player = self.world:GetPlayer()

    self:RenderPlayerDetails( ui, player )
    ui.Separator()

    self:RenderLocationDetails( ui, player:GetLocation(), player )
    ui.Separator()
    ui.End()


    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove" }
	ui.SetNextWindowSize( love.graphics.getWidth(), love.graphics.getHeight() * 0.2 )
	ui.SetNextWindowPos( 0, love.graphics.getHeight() * 0.8 )

    ui.Begin( "OUTPUT", true, flags )
    self:RenderSenses( ui, player )
    ui.End()
end

function GameScreen:RenderPlayerDetails( ui, player )
    ui.TextColored( 0.5, 1.0, 1.0, 1.0, player:GetName() )
    ui.SameLine( 0, 20 )
    ui.Text( "HP: 3/3" )
end

function GameScreen:RenderLocationDetails( ui, location, agent )
	ui.Text( location:GetTitle() )
	ui.TextColored( 0.8, 0.8, 0.8, 1.0, location:GetDesc() )

	ui.Indent( 20 )

	for i, obj in location:Contents() do
		ui.PushID(i)
		if agent and agent:CollectInteractions( obj ) then
			ui.PushStyleColor( ui.Style_Text, 0, 1, 1, 1 )
			if ui.Selectable( obj:GetShortDesc() ) then
				ui.OpenPopup( "INTERACT" )
			end
			ui.PopStyleColor()

			if ui.IsItemHovered() and is_instance( obj, Agent ) then
				ui.BeginTooltip()
				self:RenderAgentDetails( ui, obj )
				ui.EndTooltip()
			end

		elseif DEV then
			ui.PushStyleColor( ui.Style_Text, 0.5, 0.5, 0.5, 1 )
			if ui.Selectable( obj:GetShortDesc() ) then
				ui.OpenPopup( "INTERACT" )
			end
			ui.PopStyleColor()			
		else
			ui.TextColored( 0.5, 0.5, 0.5, 1.0, obj:GetShortDesc() )
		end

		if ui.BeginPopup( "INTERACT" ) then
			local t = agent:CollectInteractions( obj, {} )
			for i, verb in ipairs( t ) do
				local ok, details = verb:CanInteract( agent, obj )		
				if ui.MenuItem( tostring( details )) then
					verb:Interact( agent, obj )
				end
			end
			if DEV then
				if #t > 0 then
					ui.Separator()
				end
				if ui.MenuItem( "Debug" ) then
					DBG( obj )
				end
			end
			ui.EndPopup()
		end
		ui.PopID()
	end

	if agent then
		local t = agent:CollectInteractions( nil, {} )
		for i, verb in ipairs( t ) do
			local ok, details = verb:CanInteract( agent, nil )
			ui.PushStyleColor( ui.Style_Text, 1, 1, 0, 1 )
			if ui.Selectable( tostring(details) ) then
				verb:Interact( agent, nil )
			end
			ui.PopStyleColor()
		end
	end
	ui.Unindent( 20 )
end

function GameScreen:RenderAgentDetails( ui, agent )
	ui.Text( "HP:" )
	ui.SameLine( 0, 10 )
	ui.TextColored( 1, 0, 0, 1, string.format( "%d/%d", 3, 3 ))
end

function GameScreen:RenderSenses( ui, player )
	for i, txt in player:Senses() do
		ui.Text( txt )
	end
	ui.SetScrollHere()
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
