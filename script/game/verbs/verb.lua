local Verb = class( "Verb" )

function Verb:init( actor, obj )
	-- assert( is_instance( actor, Agent ))
	self.actor = actor
	self.obj = obj
end

function Verb:SetEndTime( end_time )
	self.end_time = end_time
end

function Verb:GetFlags()
	if self.verb then
		return self.verb:GetFlags()
	else
		return bit32.bor( self.FLAGS or 0, self.flags or 0 )
	end
end

function Verb:IsBusy( flags )
	if flags == nil then
		return true
	else
		return bit32.band( self:GetFlags(), flags ) == flags
	end
end

function Verb.RecurseSubclasses( class, fn )
	class = class or Verb
	fn( class )

	for i, subclass in ipairs( class._subclasses ) do
		Verb.RecurseSubclasses( subclass, fn )
	end
end

function Verb:GetRoomDesc()
	local dc = self:GetDC()
	local desc = self:GetDesc()

	if dc == 0 then
		return desc
	else
		return loc.format( "{1} (DC: {2})", desc, dc )
	end
end

function Verb:GetDC()
	if self.dc == nil and self.CalculateDC then
		self.dc = self:CalculateDC( Modifiers() )
	end
	return self.dc or 0
end

function Verb:CheckDC()
	return math.random( 1, 20 ) >= self:GetDC()
end

function Verb:CanInteract( ... )
	return true
end

function Verb:GetDesc()
	return self._classname
end

function Verb:GetShortDesc( viewer )
	if self.ACT_DESC then
		if self.actor:IsPuppet() then
			return loc.format( self.ACT_DESC[1], self.actor:LocTable( viewer ), self.obj and self.obj:LocTable( viewer ))
		else
			return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ), self.obj and self.obj:LocTable( viewer ))
		end
	end
end


function Verb:_BeginActing( actor )
	self.actor = actor
	
	self:Interact( actor )

	if self.end_time and self.end_time > actor.world:GetDateTime() then
		self:YieldForTime( self.end_time - actor.world:GetDateTime() )
	end
	
	self:EndActing( actor )
end

function Verb:IsCancelled()
	return self.cancelled == true
end

function Verb:Cancel()
	self.cancelled = true

	self.actor.world:UnscheduleEvent( self.yield_ev )
	self.actor.world:TriggerEvent( self.yield_ev )
end

function Verb:CanCancel()
	return true
end

function Verb:EndActing( actor )
	actor:_RemoveVerb( self )
	
	if self.yield_ev then
		self.actor.world:UnscheduleEvent( self.yield_ev )
		self.yield_ev = nil
	end

	self.yield_duration = nil
end

function Verb:GetActingProgress()
	if self.yield_ev and self.yield_duration then
		return 1.0 - (self.yield_ev.when - self.actor.world:GetDateTime()) / self.yield_duration
	end
end


function Verb:YieldForTime( duration )
	assert( duration > 0 )

	self.yield_ev = self.actor.world:ScheduleFunction( duration, self.Resume, self, coroutine.running() )
	self.yield_duration = duration
	return coroutine.yield()
end

function Verb:Resume( coro )
	self.yield_ev = nil
	self.yield_duration = nil

	local ok, result = coroutine.resume( coro )
	if not ok then
		error( tostring(result) .. "\n" .. debug.traceback( coro ))
	elseif coroutine.status( coro ) == "suspended" then
		-- Waiting.
	else
		-- Done!
		-- print( "DONE", self, coroutine.status(coro))
	end
end

function Verb:__tostring()
	if self.obj then
		return string.format( "<%s : %s>", self._classname, tostring(self.obj))
	else
		return string.format( "<%s>", self._classname )
	end
end
