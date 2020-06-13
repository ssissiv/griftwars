local NexusWindow = class( "NexusWindow" )

function NexusWindow:Resume( ... )
	if self.coro then
		local ok, r1, r2, r3 = coroutine.resume( self.coro, ... )
		if not ok then
			error( tostring(r1) .. "\n" .. tostring(debug.traceback( self.coro )))	
		end
		return r1, r2, r3
	end
end

