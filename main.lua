-----------------------------------------------------------
package.path = "script/?.lua;foreign/?/init.lua;foreign/?.lua;"..package.path
-----------------------------------------------------------

local strict = require "util/strict"
strictify( _G )

util = require "util/util"
constants = require "constants"
require "debug/debug_mgr"
debug_menus = require "debug/debug_menus"
loc = require "locstring"
Shaders = require "render/shader_defs"
GameScreen = require "frontend/game_screen"
Camera = require "camera"
require "calendar"
require "input"
require "eventsystem"
require "gui/ui"

require "game/msg"
require "game/location"
require "game/agent"
require "game/worldbase"
require "game/world"
require "game/worldgen"
require "game/aspects/aspect"
require "game/aspects/traits"
require "game/aspects/skills"

-----------------------------------------------------------

require "imgui"

local test_window = false
local gui = nil
local debug_mgr = nil
local myShader
local global_lcg = lcg()

function DBG( v )
    local debug_node = DebugUtil.CreateDebugNode( v )
    debug_mgr:CreatePanel( debug_node )
end

function DBQ( k, v )
    local env = debug_mgr:GetDebugEnv()
    return env and env[ k ] or v
end

function GetDbg()
    return debug_mgr
end

function GetRand( seed )
    if seed then
        global_lcg:randomseed( seed )
    end
    return global_lcg
end

-----------------------------------------------------------
--
-- LOVE callbacks
--
function love.load(arg)
    math.randomseed( os.time() )
    
    local game = GameScreen()

    gui = UI()
    gui:AddScreen( game )

    debug_mgr = DebugManager( game )
    debug_mgr:AddBindingGroup( debug_menus.GAME_BINDINGS )
    debug_mgr:ExecuteDebugFile( "script/debug/consolecommands.lua" )
end
 
function love.update(dt)
    imgui.NewFrame()
    gui:Update( dt )
end
 
function love.draw()
    love.graphics.clear(0, 0, 77, 255)

    -- Render game UI
    gui:RenderUI()

    -- Debug render
    debug_mgr:DoRender()

    love.graphics.setColor( 255, 255, 255 )
    imgui.Render()
end
 
function love.quit()
    imgui.ShutDown()
end
 
--
-- User inputs
--
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end
 
function love.keypressed(key)
    imgui.KeyPressed(key)
    if debug_mgr:IsConsoleOpen() then
        -- while console is open, allow DebugMgr to handle keys even if ImGUI sinks them.
        debug_mgr:KeyPressed( key )

    elseif not imgui.GetWantCaptureKeyboard() then
        if not debug_mgr:KeyPressed( key ) then
            gui:KeyPressed( key )
        end
    end
end
 
function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        gui:KeyReleased( key )
    end
end
 
function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        gui:MouseMoved( x, y )
    end
end
 
function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        if not debug_mgr:MousePressed( x, y, button) then
            gui:MousePressed( x, y, button )
        end
    end
end
 
function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        if not debug_mgr:MouseReleased( x, y, button) then
            gui:MouseReleased( x, y, button )
        end
    end
end
 
function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end