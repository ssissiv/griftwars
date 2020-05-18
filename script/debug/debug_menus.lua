
-----------------------------------------------------------------------
-- Some shared bindings between the editor and teh game.

local SHARED_BINDINGS =
{
    {
        Binding = InputBinding{key ="`", CTRL = true },
        EnabledForConsole = true,
        Text = "Toggle Console",
        Do = function( dbg )
            dbg:ToggleDebugConsole()
        end
    },
    {
        Binding = InputBinding{key="backspace", CTRL = true },
        Text = "Toggle Debug Render",
        Do = function( dbg )
        end
    },
    {
        Binding = InputBinding{key = "`", SHIFT = true },
        Text = "Create Inspector Panel",
        Do = function( dbg )
            local dbg_env = dbg:GetDebugEnv()
            if dbg_env.console == nil then
                dbg:CreatePanel()
            end
        end
    },
    {
        Binding = InputBinding{key = "`"},
        Text = "Toggle Inspector Panel",
        Do = function( dbg )
            local dbg_env = dbg:GetDebugEnv()
            if dbg_env.console == nil then
                dbg:TogglePanel()
            end
        end
    },
    {
        Binding = InputBinding{key="d", CTRL = true},
        EnabledForConsole = true,
        Text = function()
            return string.format( "Execute '%s'", DebugUtil.GetLocalDebugData( "DEBUG_FILE" ))
        end,
        Do = function( dbg )
            dbg:ExecuteDebugFile( DebugUtil.GetLocalDebugData( "DEBUG_FILE" ))
        end
    },
    {
        Binding = InputBinding{key="r", CTRL = true},
        Text = "Reload Game",
        Do = function( dbg )
            GetGUI():ClearScreens()
            local game = GameScreen()
            GetGUI():AddScreen( game )
        end
    },
    {
        Binding = InputBinding{key="=", CTRL = true},
        Text = "Speed Up",
        Do = function( dbg )
            local dbg_env = dbg:GetDebugEnv()
            dbg_env.debug_world_speed = clamp( (dbg_env.debug_world_speed or DEFAULT_DEBUG_SPEED) + 1, 1, #DEBUG_WORLD_SPEEDS )
            local speed = DEBUG_WORLD_SPEEDS[ dbg_env.debug_world_speed ]
            dbg_env.game.world:SetDebugTimeSpeed( speed )
        end
    },
    {
        Binding = InputBinding{key="-", CTRL = true},
        Text = "Speed Down",
        Do = function( dbg )
            local dbg_env = dbg:GetDebugEnv()
            dbg_env.debug_world_speed = clamp( (dbg_env.debug_world_speed or DEFAULT_DEBUG_SPEED) - 1, 1, #DEBUG_WORLD_SPEEDS )
            local speed = DEBUG_WORLD_SPEEDS[ dbg_env.debug_world_speed ]
            dbg_env.game.world:SetDebugTimeSpeed( speed )
        end
    },
    {
        Binding = InputBinding{key="return", CTRL = true },
        Text = "Toggle Pause",
        Enabled = function()
            return is_instance( GetGUI():GetTopScreen(), GameScreen )
        end,
        Do = function( dbg )
            local dbg_env = dbg:GetDebugEnv()
            dbg_env.game.world:TogglePause( PAUSE_TYPE.DEBUG )
        end
    },
}

-----------------------------------------------------------------------
-- Non-game based debug bindings.

local TOOL_BINDINGS =
{
    name = "Tool",
}
table.arrayadd( TOOL_BINDINGS, SHARED_BINDINGS )

-----------------------------------------------------------------------
-- In-game based debug bindings.

local GAME_BINDINGS =
{
    name = "Game",
    {
        Binding = InputBinding{ key = "t", CTRL = true },
        Text = "Debug Tile",
        Do = function( dbg )
            local env = dbg:GetDebugEnv()
            local tile = env.world.map:GetTile( env.cx, env.cy )
            DBG(tile)
        end,
    },

    {
        Binding = InputBinding{ key = "f8" },
        Text = "Quick Save",
        Do = function( dbg )
            local env = dbg:GetDebugEnv()
            env.game:SaveWorld( "quicksave.sav" )
        end,
    },

    {
        Binding = InputBinding{ key = "f9" },
        Text = "Quick Load",
        Do = function( dbg )
            local env = dbg:GetDebugEnv()
            env.game:LoadWorld( "quicksave.sav" )
        end,
    },

    {
        Binding = InputBinding{ key = "g", CTRL = true },
        Text = "God Mode",
        Do = function( dbg )
            local puppet = dbg:GetDebugEnv().puppet
            puppet:GetStat( STAT.HEALTH ):DeltaValue( 999, 999 )
            puppet:GetInventory():DeltaMoney( 1000 )
        end,
    }

}
table.arrayadd( GAME_BINDINGS, SHARED_BINDINGS )

-------------------------------------------------------------------------
-- TABLE BINDINGS

local TABLE_BINDINGS =
{
    name = "Table",
    {
        Text = function( dbg, t )
            return string.format( "set t = %s", rawstring(t))
        end,
        Checked = function( dbg, t )
            return t and dbg:GetDebugEnv().t == t
        end,
        Do = function( dbg, t )
            dbg:GetDebugEnv().t = t
        end
    },
    {
        Text = function( dbg, t )
            return string.format( "View %s", rawstring(t))
        end,
        Do = function( dbg, t )
            dbg:CreatePanel( DebugTable( t ))
        end
    },
    { }, -- SEPARATOR
    {
        Text = function( t )
            return string.format( "clear t = %s", rawstring(t))
        end,
        Do = function( t )
            table.clear( t )
        end
    }
}

-------------------------------------------------------------------------
-- DEBUG TOGGLES

local DEBUG_TOGGLES =
{
     name = "Toggles",
}

for i, k in sorted_pairs(DBG_FLAGS) do
    local flag = DBG_FLAGS[k]
    if k ~= DBG_FLAGS.NONE then
        local menu_item =
        {
            Text = tostring(k),
            Checked = function( dbg )
                return dbg:IsDebugFlagged( flag )
            end,
            Do = function( dbg )
                dbg:ToggleDebugFlags( flag )
            end,
        }
        table.insert( DEBUG_TOGGLES, menu_item )
    end
end

return
{
    GAME_BINDINGS = GAME_BINDINGS,
    TOOL_BINDINGS = TOOL_BINDINGS,
    DEBUG_TOGGLES = DEBUG_TOGGLES,
    TABLE_BINDINGS = TABLE_BINDINGS,
}

