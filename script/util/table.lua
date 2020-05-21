-- Table extentions.

function table.deepcopy(t)
    assert( type(t) == "table" )

   local t2 = {}
   for k,v in pairs(t) do
        if type(v) == "table" then
            t2[k] = table.deepcopy(v)
        else
            t2[k] = v
        end
    end
   return t2
end

function table.copykeys( t, t2 )
    if t2 == nil then
        t2 = {}
    end
    for k, v in pairs( t ) do
        table.insert( t2, k )
    end
    return t2
end

function table.unpack(...)
    return unpack(...)
end

function table.shallowcopy(orig, dest)
    local copy
    if type(orig) == 'table' then
        copy = dest or {}
        for k, v in pairs(orig) do
            copy[k] = v
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.transform( t, fn )
    local j, n = 1, #t
    for i = 1, #t do
        local v = fn( t[i] )
        if j < i then
            t[i] = nil
        end
        t[j] = v
        if v ~= nil then
            j = j + 1
        end
    end
end

function table.range( a, b )
    local t = {}
    for i = a, b do
        table.insert( t, i )
    end
    return t
end

function table.arrayremove(t, v)
    for k = 1, #t do
        if t[k] == v then
            table.remove(t, k)
            return true
        end
    end
    return false
end

function table.arraycontains(t, v)
    for k = 1, #t do
        if t[k] == v then
            return true
        end
    end
    return false
end

function table.arrayfind(t, v)
    for i, tv in ipairs(t) do
        if tv == v then
            return i
        end
    end
    return nil
end

function table.contains(t, val)
    for k, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function table.find(t, v)
    for k, tv in pairs(t) do
        if tv == v then
            return k
        end
    end
    return nil
end

function table.clear(t)
    for k,v in pairs(t) do
        t[k] = nil
    end
end

function table.reverse(t)
    local len = #t
    local half = math.floor(len /2)
    for k = 1, half do
        t[k], t[len - (k-1)] =  t[len - (k-1)], t[k]
    end
end

function table.count( t )
    local count = 0
    for k,v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.count_if( t, fn )
    local count = 0
    for k,v in pairs(t) do
        if fn(v) then
            count = count + 1
        end
    end
    return count
end

function table.maxn( t )
    local n = 0
    for i, v in pairs( t ) do
        if type(i) == "number" then
            n = math.max( i, n )
        end
    end
    return n
end

function table.shuffle(array, start_index, end_index, rnd)
    
    start_index = start_index or 1
    end_index = end_index or #array
    rnd = rnd or math.random

    local arrayCount = end_index - start_index + 1
    
    for i = end_index, start_index+1, -1 do
        local j = rnd(start_index, i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

function table.add(dst, src)
    for k,v in pairs(src) do
        assert(dst[k] == nil, "Merging duplicate into table")
        dst[k] = v
    end
end

function table.arrayadd(dst, src)
    for i,v in ipairs(src) do
        table.insert(dst, v)
    end
end

function table.insert_unique( t, val )
    for k, v in pairs(t) do
        if v == val then
            return
        end
    end
    table.insert( t, val )
end

function table.merge( ... )
    local t = {}
    for i = 1, select( "#", ... ) do
        local t2 = select( i, ... )
        table.arrayadd( t, t2 )
    end
    return t
end

function table.inherit( tbase, t )
    local tnew = shallowcopy( tbase ) -- note: shallow inheritance.
    for k, v in pairs(t) do
        tnew[k] = v
    end
    return tnew
end

table.empty = readonly({})

--finds the first index where val would be inserted to preserve ordering in the table t
local default_cmp = function(a,b) return a < b end
function table.binsearch(t, val, cmp)
    cmp = cmp or default_cmp
    local len = #t
    local min_idx = 1
    local max_idx = len--math.floor(len/2)

    while min_idx <= max_idx do
        local idx = math.floor((min_idx + max_idx)*.5)
        
        if cmp(t[idx], val) then
            min_idx = idx + 1
        else
            max_idx = idx - 1
        end
    end
    return min_idx
end

function table.binsert(t, val, cmp)
    local idx = table.binsearch(t, val, cmp)
    table.insert(t, idx, val)
end

function table.arraypick( t )
    local num = t and #t or 0
    return num > 0 and t[math.random(num)] or nil
end

function table.pick( t )
    local num = table.count( t )
    local i = math.random( num )
    for k, v in pairs(t) do
        i = i - 1
        if i <= 0 then
            return k, v
        end
    end
end
