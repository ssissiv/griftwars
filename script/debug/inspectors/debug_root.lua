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

function DebugRoot:IsFiltered( obj )
    return DebugUtil.FilterEntity( obj, self.filter_str, self.filter_tags )
end

function DebugRoot:RenderPanel( ui, panel, dbg )
    ui.Text( string.format( "%s", "BUILD_ID" ))
    ui.Text( string.format( 'Mem: %.2f MB, FPS: %.1f', collectgarbage('count') / 1000, love.timer.getFPS()))
    if ui.TreeNode( "Event Load" ) then
        ui.Text( string.format( "%d total events", self.game.world.total_events_triggered  ))

        local arr = { 5, 8, 10, 12, 15, 24, 20, 3, 3, 3, 3, 3 }
        ui.PlotHistogram("Events", arr, #arr, 0 )

        ui.TreePop()
    end

    ui.Separator()

    if ui.Button( "UI" ) then
        panel:PushDebugValue( DebugUI( GetGUI() ) )
    end

    for i, screen in GetGUI():Screens() do
        ui.SameLine( 0, 10 )
        if ui.Button( tostring(screen) ) then
            DBG( screen )
        end
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
            self.filter_tags = filter_str:split( " " )
        end

        if ui.TreeNodeEx( "Zones" ) then
            local current_zone = puppet and puppet:GetLocation() and puppet:GetLocation():GetZone()
            if current_zone then
                ui.Text( "**" )
                ui.SameLine( 0, 0 )
                panel:AppendTable( ui, current_zone )
            end
            for i, zone in ipairs( self.game.world:GetBucketByClass( Zone )) do
                if zone ~= current_zone then
                    if self:IsFiltered( zone ) then
                        panel:AppendTable( ui, zone )
                    end
                end
            end
            ui.TreePop()
        end

        if ui.TreeNodeEx( "Locations", "DefaultOpen" ) then
            if puppet and puppet:GetLocation() then
                panel:AppendTable( ui, puppet:GetLocation(), string.format( "**%s", tostring(puppet:GetLocation())) )
            end
            for i, location in self.game.world:AllLocations() do
                if self:IsFiltered( location ) then
                    panel:AppendTable( ui, location )
                end
            end
            ui.TreePop()
        end

        if ui.TreeNodeEx( "Agents", "DefaultOpen" ) then
            for i, agent in self.game.world:AllAgents() do
                if self:IsFiltered( agent ) then
                    panel:AppendTable( ui, agent )
                end
            end
            ui.TreePop()
        end

        if ui.TreeNodeEx( "Objects", "DefaultOpen" ) then
            local objs = self.game.world:GetBucketByClass( Object )
            for i, ent in ipairs( objs ) do
                if is_instance( ent, Object ) then
                    if self:IsFiltered( ent ) then
                        panel:AppendTable( ui, ent )
                    end
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
