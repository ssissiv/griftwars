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
	ui.SetNextWindowSize( love.graphics.getWidth(), 140 )
	ui.SetNextWindowPos( 0, 0 )

    ui.Begin( "ROOM", true, flags )
    local player = self.world:GetPlayer()

    self:RenderPlayerDetails( ui, player )
    ui.Separator()

    self:RenderCurrentLocation( ui, player:GetLocation() )
    ui.Separator()

    ui.End()
end

function GameScreen:RenderPlayerDetails( ui, player )
    ui.TextColored( 0.5, 1.0, 1.0, 1.0, player:GetName() )
    ui.SameLine( 0, 20 )
    ui.Text( "HP: 3/3" )
end

function GameScreen:RenderCurrentLocation( ui, location )
	ui.Text( location:GetTitle() )
	ui.TextColored( 0.8, 0.8, 0.8, 1.0, location:GetDesc() )
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
