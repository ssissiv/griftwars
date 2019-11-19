local Verb = class( "Verb" )

function Verb:init( actor, obj )
	-- assert( is_instance( actor, Agent ))
	self.actor = actor
	self.obj = obj
end

function Verb:GetFlags()
	return bit32.bor( self.FLAGS or 0, self.flags or 0 )
end

function Verb:HasBusyFlag( flags )
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
	if self.coro then
		return false, "Already executing"
	end

	return true
end

function Verb:GetDesc()
	return self._classname
end

function Verb:GetShortDesc( viewer )
	return loc.format( "{1.Id} is here doing {2}", self.actor:LocTable( viewer ), tostring(self))
end

function Verb:DidWithinTime( actor, dt )
	if self.time_finished then
		return actor.world:GetDateTime() - self.time_finished <= dt
	end

	return false
end

function Verb:DoVerb( actor, ... )
	if not actor:_AddVerb( self ) then
		return
	end

	self.actor = actor
	self.coro = coroutine.running()
	assert( self.coro )
	self.time_started = actor.world:GetDateTime()

	if actor:IsPuppet() and self.ACT_RATE then
		actor.world:SetWorldSpeed( actor.world:GetWorldSpeed() * self.ACT_RATE )
	end

	self:Interact( actor, ... )
	
	if actor:IsPuppet() and self.ACT_RATE then
		actor.world:SetWorldSpeed( actor.world:GetWorldSpeed() / self.ACT_RATE )
	end

	if self.yield_ev then
		self.actor.world:UnscheduleEvent( self.yield_ev )
		self.yield_ev = nil
	end

	self.yield_duration = nil
	self.coro = nil
	self.time_finished = actor.world:GetDateTime()

	actor:_RemoveVerb( self )
end

function Verb:IsCancelled()
	return self.cancelled == true
end

function Verb:Cancel()
	self.cancelled = true

	if self.yield_ev then
		self.actor.world:UnscheduleEvent( self.yield_ev )	
		self.actor.world:TriggerEvent( self.yield_ev )
	end
end

function Verb:CanCancel()
	return true
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

function Verb:RenderDebugPanel( ui, panel, dbg )
	ui.Columns( 2 )
	panel:AppendTable( ui, self )
	ui.NextColumn()

	if self.coro then
		panel:AppendTable( ui, self.coro )
	end
	ui.NextColumn()

	ui.Columns( 1 )
end

function Verb:__tostring()
	if self.obj then
		return string.format( "<%s : %s>", self._classname, tostring(self.obj))
	else
		return string.format( "<%s>", self._classname )
	end
end
