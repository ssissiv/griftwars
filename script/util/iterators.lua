--[[
 Iterates over entries in a table, sorted by the given sort function.
 Usage:
    for i, k, v in sorted_pairs(t, fn) do
        -- i counts from 1 .. table.count(t)
        -- k, v are the key-values from t sorted by table.sort( t, fn )
    end
--]]

local function StringSort( a, b )
    if type(a) == "number" and type(b) == "number" then
        return a < b
    else
        return tostring(a) < tostring(b)
    end
end

local function SortedKeysIter( state, i )
    i = next( state.sorted_keys, i )
    if i then
        local key = state.sorted_keys[ i ]
        return i, key, state.t[ key ]
    end
end

function sorted_pairs( t, fn )
    local sorted_keys = {}
    for k, v in pairs(t) do
        table.insert( sorted_keys, k )
    end
    table.sort( sorted_keys, fn or StringSort )
    return SortedKeysIter, { sorted_keys = sorted_keys, t = t }
end

--[[
 Iterates over <key, values> in a table that satisfy the given predicate.
 Resolves simply to pairs() if the predicate is nil.
 Usage:
     for k, v in predicate_pairs( t, function( k, v ) return type(v) == "number" end ) do
        assert( type(v) == "number" ) -- will never fail
     end
--]]

local function PredicateIterator( state, i )
    local pred, t, v = state.pred, state.t
    repeat
        i, v = next( t, i )
    until i == nil or pred( v )
    return i, v
end

function predicate_pairs( t, pred )
    if pred == nil then
        return pairs( t )
    else
        return PredicateIterator, { t = t, pred = pred }
    end
end

--[[
 Tokenizes a space or colon-delimited string into 'arguments'.
 Similar to string.split, but substrings bookended by {} constitute a single argument even with embedded spaces.
 Usage:
    local s = "one two {this is one arg} \"one string\""
    for i, arg in iargs( s ) do
        print( arg ) -- 1:one, 2:two, 3:{this is one arg} 4:one string
    end
--]]

local function IterateArgs( state, i )
    local s, sn = state.s:match( "^[%s:]*(%b{})(.*)$" )
    if s and sn then
        state.s = sn
        return (i or 0) + 1, s
    end
    local s, sn = state.s:match( "^[%s:]*(%b\"\")(.*)$" )
    if s and sn then
        state.s = sn
        return (i or 0) + 1, s:sub( 2, #s - 1 )
    end
    local s, sn = state.s:match( "^[%s:]*([^%s:]+)(.*)$" )
    if s and sn then
        state.s = sn
        return (i or 0) + 1, s
    end
end

function iargs( s )
    return IterateArgs, { s = s }
end


--[[
Iterates through a compacted array of vectors.
 Usage:
    local t = { 0, 1, 2, 4 }
    for i, x, y in ipoints( t ) do
        print( i, x, y ) -- 1, 0, 1
    end
--]]

local function IteratePoints( state, i )
    i = (i or 0) + 1
    if state.t[(i - 1) * state.dim + 1] then
        return i, table.unpack( state.t, (i - 1) * state.dim + 1, i * state.dim )
    end
end

function ipoints( t, dim )
    return IteratePoints, { t = t, dim = dim or 2 }
end
