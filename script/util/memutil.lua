-- Create a string that represents the reference path to an object.
-- eg. "foo.4.sub.field"
local function make_refpath( t )
	return table.concat( t, "." )
end

-- Create a more useful type_name for an object (o) than type() or tostring() that can be used as a search string.
local function type_name(o)
	if type(o) == "table" then
		if o == _G then
			return "_G"
		elseif o == debug.getregistry() then
			return "REGISTRY"
		end

		local meta = getmetatable(o)
		if meta and meta._classname then
			return meta._classname.."(table)"
		elseif rawget( o, "_classname" ) then
			return tostring(rawget( o, "_classname" )).."(class)"
		end
	elseif type(o) == "userdata" then
		return tostring(o).."(userdata)"
	elseif type(o) == "string" then
		return o.."(string)" -- so that raw strings can also be searched for.
	end
	return type(o)
end


-- Recurses through all the fields of table t.
-- For each table/function/thread found therein, f() will be called with the pathstack exactly once.
local function recurse_table( t, f )
	local refs_seen = setmetatable( {}, { __mode = 'k' })
	local pathstack = {}
	local main_coroutine = debug.getregistry()[1]

	local recurse_value
	recurse_value = function(v, name)
		if v == refs_seen or v == main_coroutine then
			return
		end
		if refs_seen[v] then
			return
		end

		if type(v) ~= "string" and type(v) ~= "number" then
			refs_seen[v] = true
		end
		pathstack[#pathstack+1] = name

		if f(v, pathstack) then
			if type(v) == "table" then
				for k,v in pairs(v) do
					recurse_value(v, tostring(k))
					recurse_value(k, "["..tostring(k).."]")
				end

			elseif type(v) == "function" then
				local i = 1
				while true do
					local upvalname, upval = debug.getupvalue(v, i)
					if not upvalname or upval == nil then break end
					recurse_value(upval, upvalname)
					i = i + 1
				end

			elseif type(v) == "thread" then
				local depth = 1
	            local dbg = debug.getinfo( v, depth )
	            if dbg == nil then
	            	-- This means a coroutine was created but never resumed.  Such a coroutine can hold upvalues to references,
	            	-- but is impenetrable to inspection because debug.getinfo() will always return nil for such a coroutine.
	            	print( "WARNING:", coroutine.status( v ), tostring(v), name )
	            end
	            while dbg do
	            	-- local vars at this level.
	            	local idx = 1
	            	while true do
						local name, val = debug.getlocal( v, depth, idx )
						if not name then
							break
						elseif val ~= nil then
							recurse_value( val, string.format( "%s(co-local-%d)", name, idx ))
						end
						idx = idx + 1
					end

	            	-- local parameters at this level.
					idx = -1
					while true do
						local name, val = debug.getlocal( v, depth, idx )
						if not name then
							break
						elseif val ~= nil then
							recurse_value( val, string.format( "%s(co-arg%d)", name, idx ))
						end
						idx = idx - 1
					end

					-- function upvalues
		            if dbg.func then
						recurse_value( dbg.func, dbg.source or "???" )
		            end

	            	depth = depth + 1
	            	dbg = debug.getinfo( v, depth )
	            end
			end
		end

		pathstack[#pathstack] = nil
	end

	recurse_value( t, type_name(t) )
end


 -- Collect all references to a raw value (obj) or a type (typename, allow_partial)
local function CollectReferences(obj, typename, allow_partial)
	local ref_paths = {}
	local function enumerate(o, path)
		local found = false
		if obj ~= nil then
			found = o == obj
		else
			local ostr = type_name(o)
			found = allow_partial and ostr:find(typename) or ostr == typename
		end

		if found then
			local path = make_refpath( path )
			if #path > 2048 then
				-- This sad business is because the ref paths can get so long that our string buffer
				-- truncates it on the engine side.  The tail end of this path is what's important.
				path = path:sub( #path - 2048 )
			end
			if obj then
				-- Collect all references to this object.
				table.insert( ref_paths, path )
			else
				-- Track only a single reference to any given matching obj.
				ref_paths[o] = path
			end
			return false
		else
			return true
		end
	end

	recurse_table( debug.getregistry(), enumerate )
	return ref_paths
end


local function TraceReferences( obj )
	local ref_paths = CollectReferences( obj )
	print( "--REFERENCES TO:", obj )
	for i, path in pairs(ref_paths) do
		print( i, path )
	end
end

local function TraceObjects(typename, allow_partial)
	local ref_paths = CollectReferences(nil, typename, allow_partial)
	print( "--REFERENCES TO TYPE:", typename )
	for o, path in pairs(ref_paths) do
		print( type_name(o), path )
	end
end

local tracenew_seen = {} -- Cumulative table of objects already traced.
local trace_typename = nil -- Currently tracing this typename
setmetatable(tracenew_seen, { __mode = 'k' })

local function TraceNewObjects(typename, allow_partial)

	local first_run = (typename ~= trace_typename)
	if first_run then
		table.clear( tracenew_seen )
		trace_typename = typename
	end

	local ref_paths = {}
	local function enumerate( o, path )
		if not tracenew_seen[o] then
			local ostr = type_name(o)
			if allow_partial and ostr:find(typename) or ostr == typename then
				ref_paths[o] = make_refpath(path)
				tracenew_seen[o] = true
			end
		end
		return true
	end
	recurse_table( debug.getregistry(), enumerate )

    if first_run then
		print ( string.format( "Took first snapshot, found %d references. Run again to diff.", table.count(ref_paths)))

	else
		print ("---NEW REFERENCES TO:", typename)	
		for k, path in pairs(ref_paths) do
			print( type_name(k), path)
		end
	end
end

local function CheckEntityRefs()
	collectgarbage()

	local typestr = "Entity(table)"
	local ref_paths = CollectReferences( nil, typestr )
	if next(ref_paths) ~= nil then
		local msg = string.format("Found %d lua objects of type [%s] still around. Complain to a programmer.", table.count(ref_paths), typestr)
		print(msg)
		print( "--REFERENCES TO TYPE:", typestr )
		for o, path in pairs(ref_paths) do
			print( type_name(o), path )
		end
		engine.inst:ShowWarning( msg )
	else
		print( "CheckEntityRefs() -- All okay!" )
	end
end

return
{
	-- Use to find newly created instances of objects.
	-- Run once to create a snapshot of all current references, then again to output all new references.
	-- Parameters:
	--		typename: a string to match (see type_name for how objects are stringized for comparison)
	--		allow_partial: whether the string can be partial match
	-- eg:
	-- TraceNewObjects( "Entity(table)" )	-- Run again to track all new entity instances since the first command.

	TraceNewObjects = TraceNewObjects,

	-- Use to track references to objects of a given typename.
	-- Parameters:
	--		typename: a string to match (see type_name for how objects are stringized for comparison)
	--		allow_partial: whether the string can be partial match
	-- eg:
	-- TraceObjects( "Entity", true )	-- Prints all references to values o where type_name(o) contains "Entity".
	TraceObjects = TraceObjects,

	-- Use to track references to literal values.
	-- Parameters:
	--		obj: the literal object to match, using operator==
	-- eg:
	-- TraceReferences( 999 )  -- Prints all found values of 999.
	-- TraceReferences( t )	-- Prints all found referenecs to table 't'
	-- TraceReferences( "Sal" )	-- Prints all found referenecs to the string "Sal"
	TraceReferences = TraceReferences,

	-- Simply call to see if there exist any current entity references.
	CheckEntityRefs = CheckEntityRefs,
}
