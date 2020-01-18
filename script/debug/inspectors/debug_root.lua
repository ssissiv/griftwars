--------------------------------------------------------------------
-- A debug root level node.

local DebugRoot = class( "DebugRoot", DebugNode )

DebugRoot.MENU_BINDINGS = { debug_menus.DEBUG_TOGGLES }

function DebugRoot:init( game )
    assert( game )
    self.game = game
    self.frame_times = {}
    self.frame_offset = 1
end

function DebugRoot:RenderPanel( ui, panel, dbg )
    ui.Text( string.format( "%s\n\n", "BUILD_ID" ))
    ui.Separator()

    if ui.Selectable( "UI" ) then
        panel:PushDebugValue( DebugUI( GetGUI() ) )
    end

    if self.game then
        panel:AppendTable( ui, self.game, "Game" )

        ui.SameLine( 0, 5 )
        panel:AppendTable( ui, self.game.world, "World" )

        local puppet = self.game.world:GetPuppet()
        if puppet then
            ui.SameLine( 0, 5 )
            panel:AppendTable( ui, self.game.world:GetPuppet() )
        end

        local changed, filter_str = ui.InputText( "Filter", self.filter_str or "", 128 )
        if changed then
            self.filter_str = filter_str
        end

        if ui.TreeNodeEx( "Locations", "DefaultOpen" ) then
            if puppet and puppet:GetLocation() then
                panel:AppendTable( ui, puppet:GetLocation(), string.format( "**%s", tostring(puppet:GetLocation())) )
            end
            for i, location in self.game.world:AllLocations() do
                if self.filter_str == nil or string.find( tostring(location), self.filter_str ) then
                    panel:AppendTable( ui, location )
                end
            end
            ui.TreePop()
        end

        if ui.TreeNodeEx( "Agents", "DefaultOpen" ) then
            for i, agent in self.game.world:AllAgents() do
                if self.filter_str == nil or string.find( tostring(agent), self.filter_str ) then
                    panel:AppendTable( ui, agent )
                end
            end
            ui.TreePop()
        end
    end


    if ui.TreeNodeEx( "Render", { "DefaultOpen" } ) then
        ui.Indent( 20 )
        ui.Unindent( 20 )
        ui.TreePop()
    end

    if ui.TreeNodeEx( "Tools", { "DefaultOpen" } ) then
        ui.TreePop()
    end
end
