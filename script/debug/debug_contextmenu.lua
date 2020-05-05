local DebugUtil = require "debug/debug_util"
local debug_menus = require "debug/debug_menus"

-------------------------------------------------
-- Renders a debug panel with immediate mode GUI.

local DebugContextMenu = class( "DebugContextMenu", DebugPanel )

function DebugContextMenu:init( dbg, mx, my )
	DebugPanel.init( self, dbg )
	self.mx, self.my = mx, my
end

function DebugContextMenu:RenderPanel( ui )
    if self.mx and self.my then
        ui.Text( string.format( "%.2f, %.2f", self.mx, self.my ))
        ui.Separator()
    end

    local top = GetGUI():GetTopScreen()
    if top and top.RenderDebugContextPanel then
        top:RenderDebugContextPanel( ui, self, self.mx, self.my )
    end
end
