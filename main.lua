-----------------------------------------------------------
package.path = "script/?.lua;foreign/?/init.lua;foreign/?.lua;"..package.path
-----------------------------------------------------------

START_TIME = love.timer.getTime()

local strict = require "util/strict"
strictify( _G )

CONFIG = require "config"
util = require "util/util"
constants = require "constants"
assets = require "assets"
require "input"
require "debug/debug_mgr"
debug_menus = require "debug/debug_menus"
loc = require "locstring"
Shaders = require "render/shader_defs"
require "render/AtlasedImage"

require "frontend/RenderScreen"
require "frontend/game_screen"
require "frontend/LoadScreen"
require "frontend/MapScreen"
require "frontend/Nexus"
require "frontend/NexusWindow"
require "frontend/ShopWindow"
require "frontend/SleepWindow"
require "frontend/InventoryWindow"
require "frontend/AgentDetailsWindow"
require "frontend/ObjectDetailsWindow"
require "frontend/AffinityChangedWindow"
require "frontend/MemoryWindow"
require "frontend/ChallengeWindow"
require "frontend/ChoiceWindow"
require "frontend/VerbMenu"
require "frontend/Floater"
require "frontend/UIHelpers"

require "camera"
bit32 = require "bit"
require "calendar"
require "eventsystem"
require "gui/ui"

require "game/game_constants"
require "game/loot_constants"
require "game/tuning"
require "game/msg"
require "game/modifiers"
require "game/entity"
require "game/Engram"
require "game/location"
require "game/Object"
require "game/ObjectQuery"
require "game/LocationUtil"
require "game/Waypoint"
require "game/Token"
require "game/AgentViz"
require "game/agent"
require "game/archetypes"
require "game/AgentQuery"
require "game/AgentClassGenerator"
require "game/Faction"
require "game/worldbase"
require "game/world"
require "game/PathFinder"
require "game/TilePathFinder"
require "game/Raycast"
require "game/worldgen"
require "game/Req"
require "game/VerbContainer"
require "game/zones/Zone"
require "game/map/TileMapCursor"
require "game/PolymorphicHelpers"

require "game/relationships/Relationship"
require "game/relationships/Affinity"
require "game/relationships/Subordinate"

require "game/aspects/aspect"
require "game/aspects/features/Feature"
require "game/verbs/verb"
require "game/verbs/Plan"

-----------------------------------------------------------

require "imgui"

local test_window = false
local gui = nil
local debug_mgr  = DebugManager()
debug_mgr:AddBindingGroup( debug_menus.GAME_BINDINGS )

local myShader
local global_lcg = lcg()
local update_frame = 0

function GetFrame()
    return update_frame
end

function GetGUI()
    return gui
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

local function LoadAllScripts( dir )
    local files = love.filesystem.getDirectoryItems( "script/"..dir )
    for k, file in ipairs(files) do
        local filename = file:match( "^(.+)[.]lua$" )
        if filename then
            require( dir .. "/" ..filename )
        end
    end
end

function love.load(arg)
    math.randomseed( os.time() )

    print( "START_TIME=", START_TIME, os.date() )

    assets:LoadAll()

    LoadAllScripts( "game/aspects" )
    LoadAllScripts( "game/aspects/skills" )
    LoadAllScripts( "game/aspects/features" )
    LoadAllScripts( "game/aspects/StatusEffects" )
    LoadAllScripts( "game/verbs" )
    LoadAllScripts( "game/characters" )
    LoadAllScripts( "game/objects" )
    LoadAllScripts( "game/locations" )
    LoadAllScripts( "game/zones" )
    LoadAllScripts( "game/factions" )
    LoadAllScripts( "game/tilemaps" )
    LoadAllScripts( "game/worldgen" )

    require "game/Tile"

    gui = UI()

    debug_mgr:LoadDebugInspectors()
    debug_mgr:ExecuteDebugFile( "script/debug/consolecommands.lua" )

    local screen = LoadScreen()
    gui:AddScreen( screen )

    print( "Load done, took:", love.timer.getTime() - START_TIME, " secs" )
end
 
function love.update(dt)
    update_frame = update_frame + 1

    imgui.NewFrame()
    debug.sethook( function( hook_type ) print( "INFINITE LOOP?" ) error( "Infinite loop detected!" ) end, "", 10000000 )
    gui:Update( dt )
    debug.sethook()
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
        gui:MouseWheelMoved( x, y )
    end
end