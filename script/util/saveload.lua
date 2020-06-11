local function RecurseTable( t, seen, fn )
    if not seen[t] then
        seen[t] = true
        fn( t )
        for k, v in pairs( t ) do
            if type(v) == "table" then
                RecurseTable( v, seen, fn )
            end
            if type(k) == "table" then
                RecurseTable( k, seen, fn )
            end
        end
    end
end

-- class.__serialize assigns a classname value to t for save-load purposes, must now remove it.
local function Declassify( t )
    t._classname = nil
end

local function Classify( t )
    if t._classname then
        setmetatable( t, CLASSES[ t._classname ] )
        t._classname = nil
        if t.PostLoad then
            t:PostLoad()
        end
    end
end

function Serialize( obj )
    local s = Serpent.dump( obj, { indent = "\t" } )
    RecurseTable( obj, {}, Declassify )
    return s
end

function Deserialize( s )
    local t = assert( loadstring( s ))()
    RecurseTable( t, {}, Classify )
    return t    
end

function SerializeToFile( obj, filename )
    local s = Serpent.dump( obj, { indent = "  " } )
    local file = io.open( filename, "w+" )
    file:write( s )
    file:close()

    RecurseTable( obj, {}, Declassify )
end

function DeserializeFromFile( filename )
    local t = assert( loadfile( filename ))()
    RecurseTable( t, {}, Classify )
    return t
end

