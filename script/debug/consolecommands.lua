local memutil = require "util/memutil"

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Console Functions -- These are simple helpers made to be typed at the console.
-- These defined within the scope of a special debug environment, they are NOT
-- accessible via _G.
--
-- The function prefix denotes the general usage class for the benefit of readability
-- and autocomplete.
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

--------------------------------------------------------------
-- Debug framework functions

function dbg_toggle()
	dbg:ToggleDebugFlags( DBG_FLAGS.DETECT_ALL )
	if sim then
	    sim:ToggleDebugController()
	end
end

function dbg_diffcount()
	memutil.CountObjects(true)
end

function dbg_countobj(filter)
	memutil.CountObjects(false, filter)
end

function dbg_find(obj, allow_partial)
	memutil.FindObject(obj, allow_partial)
end

function dbg_counttype(typestr)
	memutil.GetObjectTypeCount(typestr)
end

function dbg_difftrace(objtype)
	objtype = objtype or "table"
	memutil.TraceNewObjects(objtype)
end

function dbg_tracealloc(enable)
	print (enable and "ENABLE TRACE ALLOC" or "DISABLE TRACE ALLOC")
	engine.inst:SetTraceAlloc(enable)
end

function dbg_test( filename )
	filename = "debug/tests/"..filename
	package.loaded[ filename ] = nil
	require( filename ) 
end

function ptime( wall_time )
	print( Calendar.FormatTime( wall_time, true ))
end

function pdur( wall_dt )
	print( Calendar.FormatDuration( wall_dt ))
end

-----------------------------------------------------------------------------

function p_xp( delta )
	local c = coroutine.create( function()
		puppet:GainXP( delta )

		local stat_xp = puppet.world.nexus:Sleep( puppet )
		if stat_xp then
			for stat, xp in pairs( stat_xp ) do
				puppet:AssignXP( xp, stat )
			end
		end
	end )

	coroutine.resume( c )
end

function switch( agent )
	world:SetPuppet( agent )
end

function find( str, idx )
    local tags = str:split( " " )
    for i, entity in ipairs( world.entities ) do
		if DebugUtil.FilterEntity( entity, str, tags ) then
    		idx = (idx or 1) - 1
    		if idx <= 0 then
    			return entity
	    	end
	    end
	end
end

function goto( str, idx )
	local location_idx, other_idx = idx or 1, idx or 1
    local tags = str:split( " " )
    local candidate
    for i, entity in ipairs( world.entities ) do
		if DebugUtil.FilterEntity( entity, str, tags ) then
	    	if is_instance( entity, Location ) then
	    		location_idx = location_idx - 1
	    		if location_idx <= 0 then
		    		candidate = entity
		    		break
		    	end

	    	elseif not candidate and entity.GetLocation ~= nil and entity:GetLocation() then
	    		other_idx = other_idx - 1
	    		if other_idx <= 0 then
		    		candidate = entity
		    	end
	    	end
	    end
	end

	if is_instance( candidate, Location ) then
		print( "goto:", candidate )
		puppet:TeleportToLocation( candidate )
	elseif candidate then
		print( "goto:", candidate )
		puppet:TeleportToLocation( candidate:GetLocation() )
	else
		print( "No goto target found." )
	end
end

-----------------------------------------------------------------------------

-- Shows all functions in the dbg_env.
function help()
	local str, funcs = {}, {}
	for k, v in pairs(dbg:GetDebugEnv()) do
		if k ~= "__index" then
			local clr
			if type(v) == "number" then
				clr = "ff5577"
			elseif type(v) == "string" then
				clr = "777700"
			elseif type(v) == "table" then
				clr = "555555"
			elseif type(v) == "function" then
				table.insert( funcs, k )
			else
				clr = "00ffff"
			end
			if clr then
				table.insert( str, string.format( "%s (%s)", tostring(k), clr, tostring(v) ))
			end
		end
	end
	table.sort( funcs )
	print( "\n\n---FUNCTIONS---\n"..table.concat( funcs, ", ").."\n\n---VARS---\n"..table.concat( str, ", " ))
end