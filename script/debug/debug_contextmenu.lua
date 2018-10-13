local DebugUtil = require "debug/debug_util"
local debug_menus = require "debug/debug_menus"

-------------------------------------------------
-- Renders a debug panel with immediate mode GUI.

local DebugContextMenu = class( "DebugContextMenu", DebugPanel )

function DebugContextMenu:RenderPanel( ui, wx, wz )
    if not wx or not wz then
        return
    end

    ui.Text( string.format( "%.2f, %.2f", wx, wz ))
    ui.Separator()

    if ui.BeginMenu( "Debug Flags" ) then
        self:AddDebugMenu( ui, debug_menus.DEBUG_TOGGLES )
        ui.EndMenu()
    end

    self:AddDebugMenu( ui, debug_menus.DEBUG_CONTEXT_MENU, { wx, wz } )
end
