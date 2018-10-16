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
    local puppet = self.world:GetPuppet()

    self:RenderAgentDetails( ui, puppet )
    ui.Separator()

    self:RenderLocationDetails( ui, puppet:GetLocation(), puppet )
    ui.Separator()

    self:RenderAgentFocus( ui, puppet )
    ui.End()


    local flags = { "NoTitleBar", "AlwaysAutoResize", "NoMove" }
	ui.SetNextWindowSize( love.graphics.getWidth(), love.graphics.getHeight() * 0.2 )
	ui.SetNextWindowPos( 0, love.graphics.getHeight() * 0.8 )

    ui.Begin( "OUTPUT", true, flags )
    self:RenderSenses( ui, puppet )
    ui.End()
end

function GameScreen:RenderAgentDetails( ui, puppet )
    ui.TextColored( 0.5, 1.0, 1.0, 1.0, puppet:GetName() )
    ui.SameLine( 0, 20 )
    ui.Text( "HP: 3/3" )

    ui.SameLine( 0, 40 )
    ui.TextColored( 1, 1, 0, 1, loc.format( "{1#money}", puppet:GetInventory():GetMoney() ))
end

function GameScreen:RenderLocationDetails( ui, location, agent )
	ui.Text( location:GetTitle() )
	ui.TextColored( 0.8, 0.8, 0.8, 1.0, location:GetDesc() )
	ui.Spacing()

	ui.Indent( 20 )

	for i, obj in location:Contents() do
		ui.PushID(i)
		if agent ~= obj then
			ui.PushStyleColor( ui.Style_Text, 0, 1, 1, 1 )
			if ui.Selectable( obj:GetShortDesc(), agent:GetFocus() == obj ) then
				agent:SetFocus( obj )
			end
			ui.PopStyleColor()
		end
		if DEV and Input.IsControl() and ui.IsItemClicked() then
			DBG( obj )
			break
		end

		ui.PopID()
	end

	if agent then
		local t = agent:CollectInteractions( nil, {} )
		for i, verb in ipairs( t ) do
			local ok, details = verb:CanInteract( agent, nil )
			if is_instance( verb, Feature ) then
				ui.PushStyleColor( ui.Style_Text, 1, 0, 1, 1 )				
			else
				ui.PushStyleColor( ui.Style_Text, 1, 1, 0, 1 )
			end
			if ui.Selectable( verb:GetDesc() ) then
				verb:Interact( agent, nil )
			end
			ui.PopStyleColor()
		end
	end
	ui.Unindent( 20 )
end

function GameScreen:RenderAgentFocus( ui, agent )
	local focus = agent:GetFocus()
	if focus == nil then
		return
	end

	self:RenderAgentDetails( ui, focus )
	ui.Text( focus:GetDesc() )
	ui.Indent( 20 )

	local t = agent:CollectInteractions( focus, {} )
	for i, verb in ipairs( t ) do
		local ok, details = verb:CanInteract( agent, focus )
		if not ok then
			ui.TextColored( 0.5, 0.5, 0.5, 1, verb:GetDesc() )
		elseif ui.Selectable( verb:GetDesc( focus ) ) then
			verb:Interact( agent, focus )
		end

		if ui.IsItemHovered() and details then
			ui.SetTooltip( details )
		end
	end

	ui.Unindent( 20 )
	ui.NewLine()

	if ui.Button( "Release focus" ) then
		agent:SetFocus()
	end

end

function GameScreen:RenderSenses( ui, agent )
	for i, txt in agent:Senses() do
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
