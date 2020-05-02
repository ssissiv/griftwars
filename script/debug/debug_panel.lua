local DebugUtil = require "debug/debug_util"
local debug_menus = require "debug/debug_menus"

-------------------------------------------------
-- Renders a debug panel with immediate mode GUI.

local DebugPanel = class( "DebugPanel" )
local next_uid = 1
local DEFAULT_WIDTH, DEFAULT_HEIGHT = 350, 400

function DebugPanel:init( dbg, node )
    self.nodes = {} -- stack of debug nodes
    self.idx = 0 -- Current index into self.nodes
    self.uid = next_uid
    next_uid = next_uid + 1
    self.dbg = dbg
    self.init_trace = debug.traceback()

    if node then
        self:PushNode( node )
    end
end

function DebugPanel:Close(  )
    self._wants_to_close = true
end

function DebugPanel:GetNode()
    return self.nodes[ self.idx ]
end

function DebugPanel:OnClose()
    local node = self:GetNode()
    if node then
        if node.OnDeactivate then
            node:OnDeactivate( self )
        end
    end
    table.clear( self.nodes )
    self.idx = 0
end

local PANEL_FLAGS = { "MenuBar" }

function DebugPanel:RenderPanel( dbg )
    local ui = dbg.imgui
    self.frame_uid = 0 -- For ensuring ID uniqueness of different widgets with the same values.
    local node = self:GetNode()
    if node ~= self.last_node then
        if self.last_node and self.last_node.OnDeactivate then
            self.last_node:OnDeactivate()
        end

        self.last_node = node

        if node and node.OnActivate then
            node:OnActivate( self )
        end
    end

    local title = string.format( "%s (%d/%d)##%uid-d", node:GetName(), self.idx, #self.nodes, self.uid )
    ui.SetNextWindowSize( node.PANEL_WIDTH or DEFAULT_WIDTH, node.PANEL_HEIGHT or DEFAULT_HEIGHT, "Once" )
    local show = ui.Begin( title, true, PANEL_FLAGS )
    if show then
        if ui.BeginMenuBar() then
            if node.can_reload and node._file then
                if ui.Button( "*" ) then
                    local filename = node._file:match( "^[.][.]/scripts/(.+)[.]lua$" )
                    package.loaded[ filename ] = nil
                    local ok, err = pcall( require, filename )
                    if not ok then
                        LOGWARN( "WARNING: Failed to load debug inspector '%s'\n%s", filename, err )
                    end
                end
                if ui.IsItemHovered() then
                    ui.SetTooltip( string.format( "Reload %s", node._file ))
                end
                ui.SameLine( 0, 5 )
            end

            if ui.Button( " < " ) and self.idx > 1 then
                self:GoBack()
            end
            ui.SameLine( 0, 5 )
            if ui.Button( " > " ) and self.idx < #self.nodes then
                self:GoForward()
            end
            ui.SameLine( 0, 20 )

            if ui.BeginMenu( "Menu" ) then
                if ui.MenuItem( "Back" ) and self.idx > 1 then
                    self:GoBack()
                end
                if ui.MenuItem( "Forward" ) and self.idx < #self.nodes then
                    self:GoForward()
                end
                if ui.MenuItem( "View Root" ) then
                    self:PushNode( DebugRoot( self.dbg ) )
                end
                if ui.MenuItem( "Init stack" ) then                
                end
                if ui.IsItemHovered() then
                    ui.SetTooltip( tostring(self.init_trace) )
                end
                if ui.MenuItem( "Debug Panel" ) then
                    DBG( self )
                end
                ui.Separator()
                if ui.MenuItem( "Close" ) then
                    show = false
                end
                ui.EndMenu()
            end

            if node.MENU_BINDINGS then
                for i, menu in ipairs( node.MENU_BINDINGS ) do
                    if ui.BeginMenu( menu.name or "???" ) then
                        self:AddDebugMenu( dbg, ui, menu, node.menu_params or table.empty )
                        ui.EndMenu()
                    end
                end
            end

            if node.menu_params and ui.BeginMenu( debug_menus.TABLE_BINDINGS.name ) then
                self:AddDebugMenu( dbg, ui, debug_menus.TABLE_BINDINGS, node.menu_params or table.empty )
                ui.EndMenu()
            end

            for i, bindings in ipairs( self.dbg.debug_bindings) do
                if ui.BeginMenu( bindings.name or "???" ) then
                    self:AddDebugMenu( dbg, ui, bindings )
                    ui.EndMenu()
                end
            end

            if ui.BeginMenu( "Help" ) then
                if ui.MenuItem( "Demo" ) then
                    self.show_test_window = true
                end
                ui.EndMenu()
            end

            ui.EndMenuBar()
        end

        if node.RenderPanel then
            node:RenderPanel( ui, self, dbg )
        else
            ui.TextColored( 1, 0, 0, 1, "NOT YET IMPLEMENTED" )
        end
    end
    ui.End()

    if self.show_test_window then
        self.show_test_window = ui.ShowTestWindow( true )
    end

    return show
end

function DebugPanel:PushNode( node )
    if not is_instance( node, DebugNode ) then
        node = DebugUtil.CreateDebugNode( node )
    end

    -- Clear forward history.
    while #self.nodes > self.idx do
        table.remove( self.nodes )
    end
    table.insert( self.nodes, node )
    self.idx = #self.nodes
end

function DebugPanel:PushDebugValue( v )
    local node
    if is_instance( v, DebugNode ) then
        node = v
    else
        node = DebugUtil.CreateDebugNode( v )
    end
    if love.keyboard.isDown( "lshift" ) or love.keyboard.isDown( "rshift" ) then
        self.dbg:CreatePanel( node )
    else
        self:PushNode( node )
    end
end

function DebugPanel:GoBack()
    self.idx = self.idx - 1
    assert( self.idx >= 1 )
end

function DebugPanel:GoForward()
    self.idx = self.idx + 1
    assert( self.idx <= #self.nodes )
end

----------------------------------------------------------------------
-- Helper wrappers for composite imgui rendering.

function DebugPanel:CollapsingHeader( ui, title, flags )
    return ui.CollapsingHeader( title, flags or "DefaultOpen" )
end

function DebugPanel:AddDebugMenu( dbg, ui, menu, menu_params )
    menu_params = menu_params or table.empty
    for i, option in ipairs( menu ) do
        if option.Visible == false or (type(option.Visible) == "function" and not option.Visible( table.unpack( menu_params ))) then
            -- Invalid for this thingy.
        else
            local txt
            if type(option.Text) == "string" then
                txt = option.Text
            elseif type(option.Text) == "function" then
                txt = option.Text( dbg, table.unpack( menu_params ) )
            end
            if option.Binding then
                txt = (txt or "") .. string.format( " (%s)", option.Binding:GetBindingString() )
            end

            if txt == nil then
                ui.Separator()
            else
                local checked = type(option.Checked) == "function" and option.Checked( dbg, table.unpack( menu_params ))
                local enabled, tt = true
                if type(option.Enabled) == "function" then
                    enabled, tt = option.Enabled( dbg, table.unpack( menu_params ))
                end
                if option.Menu then
                    local menu = type(option.Menu) == "function" and option.Menu( dbg, table.unpack( menu_params) ) or option.Menu
                    if ui.BeginMenu( txt, enabled ) then
                        self:AddDebugMenu( dbg, ui, menu, menu_params )
                        ui.EndMenu()
                    end

                elseif option.CustomMenu then
                    if ui.BeginMenu( txt, enabled ) then
                        option:CustomMenu( dbg, ui, table.unpack( menu_params ))
                        ui.EndMenu()
                    end

                elseif ui.MenuItem( txt, nil, checked, enabled ) then
                    self.dbg:RunBinding( option.Do, dbg, table.unpack(menu_params) )
                end
                if tt and ui.IsItemHovered() then
                    ui.SetTooltip( tt )
                end
            end
        end
    end
end

function DebugPanel:AppendTable( ui, v, name )
    -- Add a Button that allows pushing a new debug node for the table.
    if v == table.empty then
        ui.PushStyleColor( ui.Style_Button, 0, 0, 0, 1 )
    else
        ui.PushStyleColor( ui.Style_Button, 0, 1, 1, 1 )
    end
    ui.PushID( self.frame_uid )
    if ui.Button( tostring(name or v), 0, 14 ) and v then
        self:PushDebugValue( v )
    end

    if ui.BeginPopupContextItem( "cxt" ) then
        ui.TextColored( 0, 1, 1, 1, name or tostring(v) )

        ui.Separator()
        self:AddDebugMenu( GetDbg(), ui, debug_menus.TABLE_BINDINGS, { v } )

        local debug_class = DebugUtil.FindRegisteredClass( v )
        if debug_class and debug_class.MENU_BINDINGS then
            for i, menu in ipairs( debug_class.MENU_BINDINGS ) do
                ui.Separator()
                self:AddDebugMenu( GetDbg(), ui, menu, { v } )
            end
        end
        ui.EndPopup()
    end
    ui.PopID()
    ui.PopStyleColor()
    self.frame_uid = self.frame_uid + 1
end

function DebugPanel:AppendTableInline( ui, t, name )
    ui.PushID( self.frame_uid )
    if ui.TreeNode( name or tostring(t) ) then
        for k, v in pairs(t) do
            if type(v) == "table" then
                self:AppendTableInline( ui, v, tostring(k) )
            else
                -- Key
                ui.Text( tostring(k)..":" )
                ui.SameLine( nil, 10 )
                -- Value
                if type(v) == "string" then
                    ui.TextColored( 0, 1, 1, 1, v )

                elseif type(v) == "function" then
                    ui.TextColored( 1, 1, 0, 1, tostring(v) )

                elseif type(v) == "userdata" then
                    ui.TextColored( 1, 0, 1, 1, tostring(v) )

                else
                    ui.Text( tostring(v) )
                end
            end
        end
        ui.TreePop()
    end
    ui.PopID()
    self.frame_uid = self.frame_uid + 1
end

function DebugPanel:AppendValue( ui, v, owning_table, owning_table_key )
    if type(v) == "table" then
        self:AppendTable( ui, v )

    elseif type(v) == "string" then
        ui.TextColored( 0, 1, 1, 1, v )

    elseif type(v) == "function" then
        ui.TextColored( 1, 1, 0, 1, tostring(v) )

    elseif type(v) == "userdata" then
        ui.TextColored( 1, 0, 1, 1, tostring(v) )
    
    elseif type(v) == "number" then
        ui.TextColored( 0, 1, 0, 1, tostring(v) )

    else
        ui.Text( tostring(v) )
    end
end


function DebugPanel:AppendKeyValue( ui, key, v, t )
    -- Key
    self:AppendValue( ui, key )
    ui.NextColumn()

    -- Value
    self:AppendValue( ui, v, t, key )
    ui.NextColumn()
end

function DebugPanel:AppendKeyValues( ui, t, offset )
    local MAX_ENTRIES = 128
    offset = offset or 0 

    ui.Columns( 2, "keyvalues", false )

    local n = table.count( t )
    local more
    for i, k, v in sorted_pairs( t ) do
        if i >= offset then
            self:AppendKeyValue( ui, k, v, t )

            if i >= offset + MAX_ENTRIES then
                more = i
                break
            end
        end
    end

    ui.Columns(1)

    if more then
        ui.Separator()
        ui.TextColored( 1, 0, 1, 1, string.format( "%d more entries", n - more ))
        ui.SameLine( nil, 10 )
        
        if offset > 0 then
            ui.SameLine( nil, 10 )
            if ui.Button( "Prev..." ) then
                self:PushNode( DebugTable( t, nil, math.max( 0, offset - MAX_ENTRIES )))
            end
        end

        ui.SameLine( nil, 10 )
        if ui.Button( "Next..." ) then
            self:PushNode( DebugTable( t, nil, more ))
        end
    end
end

