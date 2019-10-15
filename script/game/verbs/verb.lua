local Verb = class( "Verb" )

function Verb:init( actor, obj )
	-- assert( is_instance( actor, Agent ))
	self.actor = actor
	self.obj = obj
end

function Verb.RecurseSubclasses( class, fn )
	class = class or Verb
	fn( class )

	for i, subclass in ipairs( class._subclasses ) do
		Verb.RecurseSubclasses( subclass, fn )
	end
end

function Verb:AssignActor( actor )
	assert( self.actor == nil or actor == self.actor )
	self.actor = actor
end

function Verb:AssignObj( obj )
	self.obj = obj
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

function Verb:CanInteract()
	return true
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


local function DoInteraction( self, actor )
	self.actor = actor
	
	self:Interact( actor )

	self:EndActing( actor )
end


function Verb:_BeginActing( actor )
	local coro = coroutine.create( DoInteraction )

	local ok, result = coroutine.resume( coro, self, actor or self.actor )
	if not ok then
		error( tostring(result) .. "\n" .. tostring(debug.traceback( coro )))
	end
end

function Verb:Cancel()
	self:EndActing()
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
	self.yield_ev = nil
	self.yield_duration = nil
end

function Verb:GetActingProgress()
	if self.yield_ev and self.yield_duration then
		return 1.0 - (self.yield_ev.when - self.actor.world:GetDateTime()) / self.yield_duration
	end
end


function Verb:YieldForTime( duration )
	if duration then
		self.yield_ev = self.actor.world:ScheduleFunction( duration, self.Resume, self )
		self.yield_duration = duration
		assert( self.coro == nil )
		self.coro = coroutine.running()
		coroutine.yield()
	end
end

function Verb:Resume()
	self.yield_ev = nil
	self.yield_duration = nil
	local coro = self.coro

	local ok, result = coroutine.resume( coro )
	if not ok then
		error( result .. debug.traceback( coro ))
	elseif coroutine.status( coro ) == "suspended" then
		assert( self.coro == coro )
	else
		-- Done!
		-- print( "DONE", self, coroutine.status(self.coro))
		self.coro = nil
	end
end

function Verb:__tostring()
	if self.obj then
		return string.format( "<%s : %s>", self._classname, tostring(self.obj))
	else
		return string.format( "<%s>", self._classname )
	end
end
