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

local function Declassify( t )
    t._classname = nil
end

local function Classify( t )
    if t._classname then
        setmetatable( t, CLASSES[ t._classname ] )
        t._classname = nil
    end
end

function SerializeToFile( obj, filename )
    local s = Serpent.dump( obj, { indent = "\t" } )
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

