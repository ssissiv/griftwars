require "debug/debug_panel"
require "debug/debug_contextmenu"
local DebugUtil = require "debug/debug_util"

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Central debug manager exposing all unified debugging support and options for the
-- game. As much as possible, this is decoupled from the core game code.
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

local dbg_env =
{
	__index = function( t, k )
		local v = rawget( _G, k )
		return v
	end
}
setmetatable( dbg_env, dbg_env )

local MAX_PRINT_HISTORY = 1024
local MAX_CMD_HISTORY = 32

-------------------------------------------------------------------
--

local DebugManager = class( "DebugManager" )

function DebugManager:init()
	self.debug_flags = DBG_FLAGS.NONE
	self.imgui = imgui
	self.debug_bindings = {}
	self.debug_panels = {}

	self:LoadDebugInspectors()
	self:LoadConsoleSettings()

	self.print_history = {}
	self.print_history_idx = 1 -- Ringbuffer index.

	local cattable = {}

	local oldprint = print
	print = function(...)
		oldprint( ... )

	    local num_args = select("#", ...)
	    for k = 1, num_args do
	        table.insert(cattable, tostring(select(k, ...)))

	    end
		local str = table.concat(cattable, '    ')
	    table.clear(cattable)

		local history, idx = self.print_history, self.print_history_idx
	    for s in string.gmatch(str.."\n", "(.-)\n") do
		    history[ idx ] = s
		    idx = (idx % MAX_PRINT_HISTORY) + 1
	    end
		self.last_print_output = os.clock()
		self.scroll_to_bottom = true
		self.print_history_idx = idx
	end
end

function DebugManager:Shutdown()
	print( "DebugManager:Shutdown()")
end

function DebugManager:GetDebugEnv()
	dbg_env.dbg = self
    dbg_env.game = self.game
    dbg_env.world = self.game.world
    dbg_env.mx, dbg_env.my = love.mouse.getPosition()
    dbg_env.gui = GetGUI()

	local screen = dbg_env.gui:GetTopScreen()
	if screen and screen.GetDebugEnv then
		screen:GetDebugEnv( dbg_env )
	end

    return dbg_env
end

function DebugManager:GetDebugUI()
	return self.imgui
end

function DebugManager:ExecuteDebugFile( filename )
	print( "Executing: ", filename )
	if filename then
		local f,e = loadfile( filename, nil, self:GetDebugEnv() )
		if not f then error(e, 2) end
		return f()
	end
end

function DebugManager:DoRender()
	if self.console_open then
		self:RenderDebugConsole()
	end

	if not self.console_open or not self.console_settings.docked then
		self:RenderDebugPanels()
	end
end

function DebugManager:LoadDebugInspectors()
	require "debug/debug_nodes"
	
	local items = love.filesystem.getDirectoryItems( "script/debug/inspectors" )
    for k, filename in ipairs( items ) do
        local name = filename:match( "^(.+)[.]lua$" )
        if name then
        	filename = string.format( "debug/inspectors/%s", name )
        	require( filename )
        end
    end 
end

function DebugManager:LoadConsoleSettings()
	self.console_settings = DebugUtil.GetLocalDebugData("CONSOLE")
	if self.console_settings == nil then
		self.console_settings = {}
		DebugUtil.SetLocalDebugData("CONSOLE", self.console_settings)
	end
	if self.console_settings.history == nil then
		self.console_settings.history = {}
	end
	self.history = self.console_settings.history
    self.history_idx = #self.history + 1
end

function DebugManager:SubmitConsoleCommand( str )
	if str ~= self.history[ #self.history ] then
		table.insert( self.history, str )
		while #self.history > MAX_CMD_HISTORY do
			table.remove( self.history, 1 )
		end
		DebugUtil.SaveLocalDebugData()
	end
	self.history_idx = #self.history + 1

	local env = self:GetDebugEnv()
	local fn, err = loadstring(str, "INP")
	if not fn then
		print ("ERROR: ", err)
	else
		setfenv( fn, env )
		local ok, res = xpcall( fn, generic_error )
		if not ok then
			print ("\n\n*****ERROR*****\n"..res.."\n\n")
		end
	end		
end

function DebugManager:ToggleDebugConsole()
	self.console_open = not self.console_open
	if self.console_settings.docked then
		--self.imgui.ToggleInputPassthrough()
	end

	local env = self:GetDebugEnv()
	if env.world then
		env.world:TogglePause( PAUSE_TYPE.CONSOLE )
	end
end

function DebugManager:IsConsoleOpen()
	return self.console_open
end

local function InputTextCallback( self, flags, key, str )
	if flags == self.imgui.TextFlags_CallbackHistory then
		if key == 3 then -- ImGuiKey_UpArrow
            self.history_idx = math.max(1, self.history_idx - 1)
		elseif key == 4 then -- ImGuiKey_DownArrow
            self.history_idx = math.min(#self.history, self.history_idx + 1)
		end
		return self.history[ self.history_idx ]

	elseif flags == self.imgui.TextFlags_CallbackCompletion then
		local AutoComplete = require "util/autocomplete"
		local t = AutoComplete( str, self:GetDebugEnv() )
		return t and t[1]

	elseif flags == self.imgui.TextFlags_CallbackAlways then
		self.last_console_input = str
	end
end

function DebugManager:RenderDebugConsole()
	local ui = self.imgui
	local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    local flags = 0
    if self.console_settings.docked then
    	flags = { "NoTitleBar", "NoResize", "NoMove", "NoScrollBar" }
		ui.SetNextWindowSize( w, h*(self.console_settings.height or 0.6) )
		ui.SetNextWindowPos( 0, 0 )
    else
		ui.SetNextWindowSize( w*0.8, h*(self.console_settings.height or 0.6), ui.ImGuiSetCond_Once )
		ui.SetNextWindowPos( 0, 0, ui.ImGuiSetCond_Once )
    end


    local show = ui.Begin( "DBG_CONSOLE", true, flags )
    if not show then
    	self:ToggleDebugConsole()

    elseif show then
    	local offset = -30
    	if self.print_filter then
    		offset = -50
    	end
	    ui.BeginChild("ScrollingRegion", 0, offset, false, ui.WindowFlags_HorizontalScrollbar )
	    -- print_history_idx points at the next line to be replaced in the buffer (ie. the current oldest entry)
	    for i = 0, MAX_PRINT_HISTORY-1 do
	    	local idx = (self.print_history_idx + i) % MAX_PRINT_HISTORY
	    	local line = self.print_history[ idx ]
	    	if line and (self.print_filter == nil or line:find( self.print_filter, 1, true )) then
		        ui.Text( line )
		    end
	    end
	    if self.scroll_to_bottom then
	    	ui.SetScrollHere()
	    	self.scroll_to_bottom = false
	    end
	    ui.EndChild()

	    local should_focus = self.force_console_focus
	    if self.console_settings.docked then
	    	should_focus = should_focus or not ui.IsAnyItemActive()
	    else
	    	should_focus = should_focus or ui.IsItemClicked()
	    end
        if ui.BeginPopupContextItem( "CXT_MENU" ) then
        	should_focus = false
        	if ui.BeginMenu( "Preferences..." ) then
        		if ui.Checkbox( "Docked", self.console_settings.docked ) then
        			if self.console_open then
        				self:ToggleDebugConsole() -- Turn off first.
        			end
        			self.console_settings.docked = not self.console_settings.docked
        			self:ToggleDebugConsole() -- Turn back on to properly set input passthru.
					DebugUtil.SaveLocalDebugData()
        		end

        		local height = ui.SliderFloat( "Height", self.console_settings.height or 0.6, 0, 1.0 ) or self.console_settings.height
        		if height ~= self.console_settings.height then
        			self.console_settings.height = height
					DebugUtil.SaveLocalDebugData()
				end
        		ui.EndMenu()
        	end
        	if ui.MenuItem( "Scroll to Bottom" ) then
        		self.scroll_to_bottom = true
        	end
        	if ui.MenuItem( "Clear History" ) then
	            table.clear( self.print_history )
	            self.print_history_idx = 1
	        end
	        if ui.BeginMenu( "Filter..." ) then
	            local filter = ui.InputText( "Filter", self.print_filter or "", 512 )
	            if ui.Button( "Clear" ) then
	            	filter = ""
	            end
	            if filter then
	            	if #filter == 0 then
	            		filter = nil
	            	end
		            self.print_filter = filter
	            end
	            ui.EndMenu()
	        end
            ui.EndPopup()
        end

        if self.print_filter then
        	ui.TextColored( 0, 1, 1, 1, string.format( "Filtered by: '%s'", self.print_filter ))
        end

	    ui.Separator()
	    ui.PushItemWidth( -40 )

	    local changed, console_input = ui.InputText( self.input_id or "", self.last_console_input or "", 1028, "EnterReturnsTrue" )
	    if changed and console_input then
	    	if #console_input == 0 then
	    		self:ToggleDebugConsole()
	    	else
		        self:SubmitConsoleCommand( console_input )
			    self.scroll_to_bottom = true
			    self.last_console_input = ""
			    self.force_console_focus = true
			    self.input_id = ""
			end
	    end
	    if should_focus then
	    	self.force_console_focus = nil
	    	ui.SetKeyboardFocusHere(-1)
	    end
	    ui.PopItemWidth()
	end
	ui.End()
end

function DebugManager:RenderDebugPanels()
	local i = 1
	while i <= #self.debug_panels do
		local panel = self.debug_panels[i]

		local ok, result = xpcall( panel.RenderPanel, generic_error, panel, self )
		if ok and panel._wants_to_close then
			result = false
		end
		if not ok or not result then
			panel:OnClose()
			table.remove( self.debug_panels, i )
			if not ok then
				error( result )
				break
			end
		else
			i = i + 1
		end
	end

	if dbg_env.show_context then
		self.imgui.OpenPopup( "DBG_CXT" )
		self.debug_contextmenu = dbg_env.show_context
		dbg_env.show_context = nil
	end

	if self.imgui.BeginPopup( "DBG_CXT" ) then
		local ok, result = xpcall(  self.debug_contextmenu.RenderPanel, generic_error, self.debug_contextmenu, self.imgui, dbg_env.wx_mark, dbg_env.wz_mark )
		if not ok then
			error( result )
		end
		self.imgui.EndPopup()
	end
end

function DebugManager:WantCaptureMouse()
	return self.imgui.WantCaptureMouse()
end

function DebugManager:Clear()
	self:ClearPanels()
	for k, v in pairs(dbg_env) do
		if type(v) ~= "function" then
			dbg_env[k] = nil
		end
	end
end

function DebugManager:ClearPanels()
	while #self.debug_panels > 0 do
		table.remove( self.debug_panels ):OnClose()
	end
end

function DebugManager:TogglePanel()
	if #self.debug_panels > 0 then
		table.remove( self.debug_panels ):OnClose()

	else
		self:CreatePanel()
	end
end

function DebugManager:CreatePanel( debug_node )
	if debug_node == nil then
		local screen -- = TheGame:FE():GetTopScreen()
		local node_class = screen and screen.GetDebugEnv and screen:GetDebugEnv( self:GetDebugEnv() )
		debug_node = node_class and node_class( screen ) or DebugRoot( self.game )
	end

	assert( is_instance( debug_node, DebugNode ))
	assert( debug_node.RenderPanel )
	local panel = DebugPanel( self, debug_node )
	table.insert( self.debug_panels, panel )
end

function DebugManager:DebugPanels()
	return ipairs( self.debug_panels )
end

function DebugManager:ShowContextMenu( panel )
	local dbg_env = self:GetDebugEnv()
	dbg_env.show_context = panel
end



function DebugManager:ToggleDebugFlags( flags )
    self.debug_flags = bit.bxor( self.debug_flags, flags )
	
	local is_debugrender = bit.band( self.debug_flags, bit.bor( DBG_FLAGS.RENDER, DBG_FLAGS.UI )) ~= 0
	self.game:FE():SetDebugRender( is_debugrender )

	if bit.band(flags, DBG_FLAGS.UI) ~= 0 then
        self.game:FE():SetDebugMode( bit.band( self.debug_flags, DBG_FLAGS.UI ) ~= 0 )
	end
end

function DebugManager:IsDebugFlagged( flag )
    return bit.band( (self.debug_flags or 0), flag ) ~= 0
end

function DebugManager:RunBinding( binding, ... )
	local ok, result = false, "Illegal binding"
	if type(binding) == "function" then
		ok, result = xpcall( binding, generic_error, ... )
	elseif type(binding) == "table" then
		local fn = binding[1]
		ok, result = xpcall( fn, generic_error, unpack( binding, 2 ))
	end
	if not ok then
		print( "DEBUG-ERR: "..tostring(result) )
	else
		return result
	end
end

function DebugManager:AddBindingGroup( bindings )
	assert( type(bindings) == "table" )
	assert( table.arrayfind( self.debug_bindings, bindings ) == nil)
	table.insert( self.debug_bindings, bindings )
end

function DebugManager:RemoveBindingGroup( bindings )
	table.arrayremove( self.debug_bindings, bindings )
end

local function CheckModifiers( binding )
	if binding.SHIFT and not Input.IsShift() then
		return false
	end
	if binding.CTRL and not Input.IsControl() then
		return false
	end
	if binding.ALT and not Input.IsAlt() then
		return false
	end
	return true
end

function DebugManager:KeyPressed( key )
	for j = #self.debug_bindings, 1, -1 do
		local debug_menu = self.debug_bindings[j]
	    for i, debug_option in ipairs(debug_menu) do
	    	local ok = debug_option.Binding and debug_option.Binding.key == key and CheckModifiers( debug_option.Binding )
	    	ok = ok and (not self.console_open or debug_option.EnabledForConsole)
	    	ok = ok and (debug_option.Enabled == nil or debug_option.Enabled( self ))
	    	if not ok and debug_option.Bindings then
		    	for i, binding in ipairs(debug_option.Bindings) do
			    	if binding and binding.key == key and CheckModifiers( binding ) then
			    		ok = true
			    		break
			        end
				end
			end
			if ok then
				self:RunBinding( debug_option.Do, self )
				return true
	        end
	    end
	end

	if self.console_open then
		if key == "up" then
            self.history_idx = math.min(#self.history, self.history_idx - 1)
			self.last_console_input = self.history[ self.history_idx ]
			self.input_id = string.format( "%d/%d", self.history_idx, #self.history )

		elseif key == "down" then
            self.history_idx = math.min(#self.history, self.history_idx + 1)
			self.last_console_input = self.history[ self.history_idx ]
			self.input_id = string.format( "%d/%d", self.history_idx, #self.history )
		end
	end
end

function DebugManager:MousePressed( x, y, button )
	if button == Input.RIGHT_MOUSE and Input.IsControl() then
		dbg_env.show_context = DebugContextMenu()
		return true
	end
	return false
end

function DebugManager:MouseReleased( x, y, button )
	return false
end

return DebugManager
