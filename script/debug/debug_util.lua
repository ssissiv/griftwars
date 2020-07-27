
local DebugUtil = class( "DebugUtil" )

function PAUSE()
    local world = GetDbg():GetDebugEnv().world
    if world and not world:IsPaused( PAUSE_TYPE.DEBUG ) then
        world:TogglePause( PAUSE_TYPE.DEBUG )
    end
end

function DBGFLAG( v )
    return GetDbg():IsDebugFlagged( v )
end

function DBG( v )
    local panel = GetDbg():FindPanel( v )
    if not panel then
        local debug_node = DebugUtil.CreateDebugNode( v )
        panel = GetDbg():CreatePanel( debug_node )
    end
    return panel
end

function DBQ( k, v )
    local env = GetDbg():GetDebugEnv()
    return env and env[ k ] or v
end

function DBSET( k, v )
    local env = GetDbg():GetDebugEnv()
    if env then
        env[ k ] = v
    end
end



function DebugUtil.FindRegisteredClass( v, base_class )
    for i, class in ipairs( get_subclasses( base_class or DebugNode )) do
        if class.REGISTERED_TYPE == type(v) then
            return class
        elseif class.REGISTERED_CLASS and is_instance( v, class.REGISTERED_CLASS ) then
            return class
        else
            local found_class = DebugUtil.FindRegisteredClass( v, class )
            if found_class then
                return found_class
            end
        end
    end
end


function DebugUtil.CreateDebugNode( v, offset )
    if v == nil then
        return DebugNil()
    elseif type(v) == "function" then
        return DebugCustom( v )
    elseif type(v) == "thread" then
        return DebugCoroutine( v )
    else
        assert( type(v) == "table" )
        -- Try to link this table to a specialized DebugNode.
        if v._class then
            local class = DebugUtil.FindRegisteredClass( v )
            if class then
                return class( v )
            end
        end

        return DebugTable( v, nil, offset )
    end
end

function DebugUtil.GetLocalDebugData( key )
    if DebugUtil.LOCAL_DATA == nil then
        local file = io.open( "script/local_debug.lua" )
        if file then
            local data = file:read("*all")
            file:close()

            local ok, result = Serpent.load( data )
            assert( ok )

            DebugUtil.LOCAL_DATA = result or {}
        else
            DebugUtil.LOCAL_DATA = {}
        end
    end

    return DebugUtil.LOCAL_DATA[ key ]
end

function DebugUtil.SetLocalDebugData( key, value )
    DebugUtil.LOCAL_DATA[ key ] = value
end

function DebugUtil.SaveLocalDebugData()
    local s = Serpent.serialize( DebugUtil.LOCAL_DATA, { sparse = false, indent = "\t" })
    --local file, err = love.filesystem.newFile("local_debug.lua")
    --print( file, err )
    local file = io.open( "script/local_debug.lua", "w+" )
    file:write( "return "..s )
    file:flush()
    file:close()
end

return DebugUtil
