-------------------------------------------------------------------
-- A debug node is simply an adapter that returns debug text for
-- a "source" object, which is literally whatever it is you want to
-- be debugging.
-- It also has a notion of child nodes, and a parent node, for easy
-- traversing of data hierarchies.

local DebugUtil = require "debug/debug_util"
local debug_menus = require( "debug/debug_menus" )
local DebugNode = class( "DebugNode" )

 -- Debug nodes may have a registered class, which automatically creates this node
 -- if linked as a table and retrieved via GetTableLink().

DebugNode.REGISTERED_CLASS = nil

function DebugNode:GetName()
    return self._classname
end

function DebugNode:GetUID()
    return self._classname -- Unique identifier for ImGUI and equating recent nodes.
end

function DebugNode:GetDesc( sb )
    sb:Append( "NO NODE" )
end

--------------------------------------------------------------------
-- Whenever attempting to create a panel for the value 'nil'

local DebugNil = class( "DebugNil", DebugNode )

DebugNil.PANEL_WIDTH = 200
DebugNil.PANEL_HEIGHT = 80

function DebugNil:RenderPanel( ui, panel )
    ui.TextColored( 1, 0, 0, 1, "nil" )
end
 
 --------------------------------------------------------------------
-- A debug source for a generic table

local DebugTable = class( "DebugTable", DebugNode )

function DebugTable:init( t, name, offset )
    self.t = t
    self.offset = offset
    self.name = name
    self.menu_params = { t }
end

function DebugTable:GetName()
    return self.name or rawstring(self.t)
end

function DebugTable:GetUID()
    return rawstring(self.t)
end

function DebugTable:RenderPanel( ui, panel )
    if self.t.RenderDebugPanel then
        self.t:RenderDebugPanel( ui, panel )
        ui.Separator()
    end

    ui.Text( string.format( "%d fields", table.count( self.t ) ))
    ui.Separator()
    
    ui.Columns(2, "mycolumns3", false)
    local mt = getmetatable(self.t)
    if mt then
        ui.Text( "getmetatable()" )
        ui.NextColumn()

        if ui.Selectable( mt._class and mt._classname or rawstring(mt) ) then
            panel:PushNode( DebugUtil.CreateDebugNode( mt ))
        end
        ui.NextColumn()
    end
    ui.Columns(1)

    panel:AppendKeyValues( ui, self.t, self.offset )
end


 --------------------------------------------------------------------
-- A debug source for a coroutine. table

local DebugCoroutine = class( "DebugCoroutine", DebugNode )

DebugCoroutine.REGISTERED_TYPE = "thread"

function DebugCoroutine:init( c )
    self.c = c
    self.locals = {}
end

function DebugCoroutine:GetName()
    return "coroutine"
end

function DebugCoroutine:RenderPanel( ui, panel )
    ui.Text( "Status:" )
    ui.SameLine( 0, 5 )
    ui.TextColored( 255, 90, 255, 255, coroutine.status( self.c ))
    ui.Text( "stack traceback:" )

    local i = 1
    while true do
        local info = debug.getinfo( self.c, i )
        if info then
            local fnname = info.name or string.format( "<%s:%d>", info.short_src, info.linedefined )
            local txt = string.format( "%s:%d in function '%s'", info.short_src, info.currentline, fnname )
            if ui.Selectable( txt ) then
                self.selected_frame = i
            end
            if self.selected_frame == i then
                ui.Indent( 20 )
                self:RenderLocals( ui, panel, i, info )
                ui.Unindent( 20 )
            end
            i = i + 1
        else
            break
        end
    end
end

function DebugCoroutine:RenderLocals( ui, panel, frame_idx, info )
    table.clear( self.locals )
    local i = 1
    while true do
        local k, v = debug.getlocal( self.c, frame_idx, i )
        if k == nil then
            break
        else
            self.locals[ k ] = v
            i = i + 1
        end
    end
    panel:AppendKeyValues( ui, self.locals )
end


--------------------------------------------------------------------
-- Dynamic, custom inspector

local DebugCustom = class( "DebugCustom", DebugNode )

DebugCustom.PANEL_FLAGS = { "AlwaysAutoResize" }

function DebugCustom:init( fn )
    self.fn = fn
end

function DebugCustom:RenderPanel( ui, panel )
    self:fn( ui, panel )
end
 