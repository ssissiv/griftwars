--
-- strict.lua
-- checks uses of undeclared global variables
-- All global variables must be 'declared' through a regular assignment
-- (even assigning nil will do) in a main chunk before being used
-- anywhere or assigned to inside a function.
--

local function what ()
	local d = debug.getinfo(3, "S")
	return d and d.what or "C"
end

local function readonly_err( t, k , v )
	error("Attempt to modify read-only table " ..tostring(k).. " = " ..tostring(v))
end

local STRICT_MT =
{
    __newindex = function(t, n, v)
	    local w = what()
	    if w ~= "main" and w ~= "C" then
		    assert(nil, "assign to undeclared variable '"..n.."'")
	    end
	    rawset(t, n, v)
    end,
 
    __index = function(t, n)
	    if what() ~= "C" then
		    assert(nil, "variable '"..tostring(n).."' is not declared")
	    end
	    return rawget(t, n)
    end
}

function strictify( t, recurse )
    local mt = getmetatable( t )
    if mt == nil then
        setmetatable(t, STRICT_MT )
        if recurse then
            for k, v in pairs(t) do
                if type(v) == "table" then
                    strictify( v, recurse )
                end
            end
        end
    end
    return t
end

function readonly( t )
	for k, v in pairs(t) do
		if type(v) == "table" then
			t[k] = readonly( v )
		end
	end
	
	return setmetatable({}, {
		__index = t,
        __len = function( t2 ) return #t end,
        __pairs = function( t2 ) return pairs(t) end,
        __ipairs = function( t2 ) return ipairs(t) end,
		__newindex = readonly_err,
		__metatable = false
	} )
end
