local Verb = class( "Verb", Aspect )

Verb.event_handlers =
{
	[ AGENT_EVENT.DIED ] = function( self, event_name, agent, ... )
		if agent:HasAspect( self ) then
			agent:LoseAspect( self )
		else
			self:Cancel()
		end
	end,
}

function Verb:init( actor, obj )
	assert( actor == nil, tostring(self) )
	self.obj = obj
	self.utility = 0
	self.actors = {}
end

function Verb:SetUtility( utility )
	self.utility = clamp( utility, 0, 100 )
end

function Verb:CalculateTimeElapsed( dt )
	if self.ACT_RATE then
		if self.ACT_RATE == math.huge then
			-- Instant
			return self.ACT_DURATION / WALL_TO_GAME_TIME
		elseif self.ACT_DURATION then
			-- Walltime
			return (dt / self.ACT_RATE) * self.ACT_DURATION / WALL_TO_GAME_TIME
		else
			-- Speedup factor
			return dt * self.ACT_RATE
		end
	else
		return dt
	end
end

function Verb:AddHelperVerb( helper )
	assert( helper._class == Verb.Help )

	if self.helpers == nil then
		self.helpers = {}
	end
	table.insert( self.helpers, helper )

	-- So that cancels will cascade to the helper verb.
	self:AddChildVerb( helper )
end

function Verb:RemoveHelperVerb( helper )
	table.arrayremove( self.helpers, helper )
	self:RemoveChildVerb( helper )
end


function Verb:GetHelpers( helpers )
	if self.helpers then
		if helpers == nil then
			helpers = {}
		end
		for i, helper in ipairs( self.helpers ) do
			table.insert_unique( helpers, helper )
		end
	end
	if self.parent then
		helpers = self.parent:GetHelpers( helpers )
	end

	return helpers
end

function Verb:Helpers()
	return ipairs( self:GetHelpers() or table.empty )
end

function Verb:AddReq( req )
	if self.reqs == nil then
		self.reqs = Aspect.Requirements()
	end
	self.reqs:AddReq( req )
end

function Verb:GetRandomActor()
	local helpers = self:GetHelpers()
	local i = math.random( (helpers and #helpers or 0) + 1 )
	if i == 1 then
		return self.actor
	else
		return helpers[i - 1].actor
	end
end

function Verb:GetActor()
	return self.actor
end

function Verb:GetTarget()
	return self.obj
end

function Verb:SetTarget( target )
	self.obj = target
	return target
end

function Verb:EqualVerb( verb )
	return verb._class == self._class and self.actor == verb.actor and self.obj == verb.obj
end

function Verb:GetOwner()
	local parent = self.parent
	while self.owner == nil and parent do
		parent = parent.parent
	end
	return self.owner
end

function Verb:OnLoseAspect( owner )
	Aspect.OnLoseAspect( self, owner )
	self:Cancel()
end

function Verb:GetWorld()
	if self.actor then
		return self.actor.world
	end
	local owner = self:GetOwner()
	if owner then
		return owner.world
	end
end

function Verb:GetFlags()
	return bit32.bor( self.FLAGS or 0, self.flags or 0 )
end

function Verb:HasBusyFlag( flags )
	if flags == nil or bit32.band( self:GetFlags(), flags ) == flags then
		return true
	elseif self.child and self.child:HasBusyFlag( flags ) then
		return true
	end

	return false
end

function Verb.RecurseSubclasses( class, fn )
	class = class or Verb
	fn( class )

	for i, subclass in ipairs( class._subclasses ) do
		Verb.RecurseSubclasses( subclass, fn )
	end
end

function Verb:GetRoomDesc( viewer )
	return self.act_desc or tostring(self)
end

function Verb:CalculateDC( dc, actor, target )
	if dc == nil then
		print( "No DC specified:", self, actor )
		return
	end
	
	local details
	if target and target.CalculateDC then
		dc, details = target:CalculateDC( dc, actor, target )
	end
	
	local details2
	dc, details2 = actor:CalculateDC( dc, self )
	if details2 and details then
		details = details .. "\n" .. details2
	end

	return dc, details
end

function Verb:CheckDC( dc, actor, target )
	local dc = self:CalculateDC( dc, actor, target )
	local roll = math.random( 0, 20 )
	local success = roll >= dc
	local result_str
	if success then
		result_str = loc.format( "Success! {1} vs. DC {2}", roll, dc )
	else
		result_str = loc.format( "Failed! {1} vs. DC {2}", roll, dc )
	end
	return success, result_str
end

function Verb:CanDo( actor, ... )
	if self.coro then
		return false, "Already executing"
	end

	for i, verb in actor:Verbs() do
		if verb:EqualVerb( self ) then
			return false, "Already executing copy"
		end
	end

	if not actor:GetLocation() then
		return false, "In limbo"
	end

	if self.FLAGS then
		local busy, verb = actor:IsBusy( self.FLAGS )
		if busy then
			return false, "Busy: "..tostring(verb)
		end
	end

	local ok, reason = self:CanInteract( actor, ... )
	if not ok then
		return false, reason
	end

	return true
end

function Verb:CanInteract( actor, target )
	if not actor:IsSpawned() or actor:IsDead() then
		return false, "Despawned or dead actor"
	end

	target = target or self.obj
	if is_instance( target, Agent ) then
		if not target:IsSpawned() then
			return false, "Despawned target"
		end
		if target:IsDead() then
			return false, "Dead target"
		end
	end

	if self.reqs then
		local ok, reason = self.reqs:IsSatisfied( actor )
		if not ok then
			return false, reason
		end
	end

	return true
end

function Verb:GetDesc( viewer )
end

function Verb:DidWithinTime( actor, dt )
	if self.time_finished then
		return actor.world:GetDateTime() - self.time_finished <= dt
	end

	return false
end

function Verb:GetDurationTook()
	if self.time_finished then
		return self.time_finished - self.time_started
	end
end

function Verb:FindVerb( verb )
	if is_class( verb ) and is_instance( self, verb ) then
		return self -- We are an instance of the verb class required.
	elseif self == verb then
		return self -- We are literally the verb required.
	end
	if self.child then
		return self.child:FindVerb( verb )
	end
end

function Verb:DoChildVerb( verb, ... )
	assert( self:IsRunning() )

	if self.cancelled then
		print( self, " attempted to DoChildVerb while cancelled!" )
		print( debug.traceback() )
		return
	end

	local ok, reason = verb:CanDo( self.actor, ... )
	if not ok then
		return false, reason
	end

	assert( self.child == nil )
	self.child = verb

	assert( verb.parent == nil )
	verb.parent = self

	local result = verb:DoVerb( self.actor, ... )

	self.child = nil
	verb.parent = nil

	return result
end

function Verb:DoVerb( actor, ... )
	assert( actor:IsDoing( self ), "not doing" )

	if self.event_handlers then
		for event_name, fn in pairs( self.event_handlers ) do
			actor:ListenForEvent( event_name, self, fn )
		end
	end

	table.insert( self.actors, actor )
	self.actor = actor
	self.world = actor.world

	self.cancelled = nil
	self.cancelled_trace = nil
	self.cancelled_frame = nil

	self.coro = coroutine.running()
	assert( self.coro )
	self.time_started = actor.world:GetDateTime()

	-- actor.world:Log( "{1} begins {2} at {3}", actor, self, actor.location )`

	self:Interact( actor, ... )

	assert( self.yield_ev == nil )
	assert( self.yield_duration == nil )
	assert( self.child == nil )

	self.coro = nil
	self.time_finished = actor.world:GetDateTime()

	for i, actor in ipairs( self.actors ) do
		actor:RemoveListener( self )
	end
	table.clear( self.actors )

	return true
end

function Verb:IsDoing()
	return self.coro ~= nil
end

function Verb:IsYielded()
	return self.coro and coroutine.status( self.coro ) == "suspended"
end

function Verb:IsRunning()
	return self.coro == coroutine.running()
end

function Verb:IsCancelled()
	return self.cancelled == true
end

function Verb:Cancel()
	if not self:IsDoing() then
		return
	end

	-- print ( "CANCEL", self, self.actor, debug.traceback())

	if self.cancelled then
		print( self, self.cancelled_frame, self.cancelled_trace )
		print( GetFrame(), self.actor, self.actor:IsDead() )
		error( "already cancelled: "..tostring(self)) 
	end

	self.cancelled = true
	self.cancelled_trace = debug.traceback()
	self.cancelled_time = self.actor.world:GetDateTime()
	self.cancelled_frame = GetFrame()

	if self.child then
		assert( self.yield_ev == nil ) -- We cannot be the yielding Verb if a child is running.
		self.child:Cancel()

	elseif self.yield_ev then
		self.actor.world:UnscheduleEvent( self.yield_ev )
		self.actor.world:TriggerEvent( self.yield_ev )
	end
end

function Verb:CanCancel()
	return true
end

function Verb:GetActingTime()
	if self.yield_ev then
		local time_left = self.yield_ev.when - self.actor.world:GetDateTime()
		return time_left, self.yield_duration
	end
end

function Verb:GetActingProgress()
	if self.yield_ev and self.yield_duration then
		local time_left = self.yield_ev.when - self.actor.world:GetDateTime()
		return time_left / self.yield_duration
	end
end

function Verb:YieldForTime( duration, how, act_rate )
	assert( duration > 0 )

	if self.cancelled then
		-- print( self, " attempted to yield while cancelled!" )
		-- print( debug.traceback() )
		return
	end

	if how == "rate" then
		-- Time is sped up by a factor of ACT_RATE
		self.ACT_RATE = act_rate
		self.ACT_DURATION = nil

	elseif how == "wall" then
		-- Time is sped up so that duration will pass in 'act_rate' wall time.
		self.ACT_RATE = act_rate
		self.ACT_DURATION = duration

	elseif how == "instant" then
		-- Time will advance by duration, instantly.
		self.ACT_RATE = math.huge
		self.ACT_DURATION = duration

	else
		self.ACT_RATE, self.ACT_DURATION = nil, nil
	end

	self.yield_ev = self.actor.world:ScheduleFunction( duration, self.Resume, self, coroutine.running() )
	self.yield_duration = duration
	local result = coroutine.yield()

	self.ACT_RATE = nil
	
	return result
end

function Verb:Unyield()
	if self.yield_ev then
		self.world:RescheduleEvent( self.yield_ev, 0 )
		return true

	elseif self.child then
		return self.child:Unyield()
	end

	return false
end

function Verb:Resume( coro )
	assert( self.yield_ev )

	self.yield_ev = nil
	self.yield_duration = nil

	if not self.cancelled then
		local ok, reason = self:CanInteract( self.actor, self.obj )
		if not ok then
			self.cant_reason = reason
			self:Cancel()
		end
	end

	self.time_resumed = self:GetWorld():GetDateTime()

	-- Even cancelled verbs get one last Resume to do any cleanup.
	-- Internally verbs should check IsCancelled after any YieldForTime call.
	local ok, result = coroutine.resume( coro )
	if not ok then
		self:ShowError( coro, result )

	elseif coroutine.status( coro ) == "suspended" then
		-- We may or may not still be part of the coro, due to being a child verb that could be cancelled, etc.
		
	else
		-- Done!
		-- print( "DONE", self, coroutine.status(coro))
	end
end

function Verb:ShowError( coro, msg )
	self:GetWorld():TogglePause( PAUSE_TYPE.ERROR )
	print( "Error resuming", self, "\n", msg )
	print( debug.traceback( coro ))
	DBG( function( node, ui, panel )
		if self.coro_dbg == nil then
			self.coro_dbg = DebugCoroutine( coro )
		end

		panel:AppendTable( ui, self )
		panel:AppendTable( ui, self.actor )
		panel:AppendTable( ui, self.obj )
		ui.Separator()

		ui.TextColored( 1, 0, 0, 1, tostring(msg) )
		ui.Spacing()

		self.coro_dbg:RenderPanel( ui, panel )

		ui.NewLine()
		if ui.Button( "Resume" ) then
			self:GetWorld():TogglePause( PAUSE_TYPE.ERROR )
		end
	end )
end


function Verb:RenderDebugPanel( ui, panel, dbg )
	ui.PushID( rawstring( self ))

	panel:AppendTable( ui, self )

	ui.Indent( 20 )
	if self.time_started then
		ui.Text( "Started:" )
		ui.SameLine( 0, 10 )
		Calendar.RenderDatetime( ui, self.time_started, self:GetWorld() )
	end
	if self.time_resumed then
		ui.Text( "Resumed:" )
		ui.SameLine( 0, 10 )
		Calendar.RenderDatetime( ui, self.time_resumed, self:GetWorld() )
	end
	if self.yield_ev then
		local time_left = self.yield_ev.when - self:GetWorld():GetDateTime()
		ui.Text( loc.format( "Resume in: {1} ({2})", time_left, Calendar.FormatDuration( time_left )))
	end

	local helpers = self:GetHelpers()
	if helpers and #helpers > 0 then
		ui.Text( "Helpers" )
		ui.Indent( 20 )
		for i, helper in ipairs( helpers ) do
			panel:AppendTable( ui, helper, tostring(helper.actor))
		end
		ui.Unindent( 20 )
	end

	if self.coro then
		ui.Text( "Thread:" )
		ui.SameLine( 0, 10 )
		panel:AppendTable( ui, self.coro )
	end

	if self.cancelled then
		ui.TextColored( 1, 0, 0, 1, "Cancelled" )
		if self.cancelled_time then
			ui.SameLine( 0, 10 )
			Calendar.RenderDatetime( ui, self.cancelled_time, self:GetWorld() )
		end
		if ui.IsItemHovered() then
			ui.SetTooltip( tostring(self.cancelled_trace) )
		end

	
	elseif self:IsDoing() then
		if ui.Button( "Cancel" ) then
			self:Cancel()
		end
	elseif self.actor == nil then
		ui.TextColored( 1, 0, 0, 1, "No Actor" )

	else
		local ok, reason = self:CanDo( self.actor )
		if not ok then
			ui.TextColored( 1, 0, 0, 1, reason or "Invalid" )
		end
	end

	if self.child then
		ui.Indent( 20 )
		self.child:RenderDebugPanel( ui, panel, dbg )
		ui.Unindent( 20 )
	end

	ui.Unindent( 20 )
	ui.PopID()
end

function Verb:__tostring()
	if self.obj and self.actor then
		return string.format( "<%s:%s-%s>", self._classname, tostring(self.actor), tostring(self.obj))
	elseif self.actor then
		return string.format( "<%s:%s>", self._classname, tostring(self.actor))
	else
		return string.format( "<%s>", self._classname )
	end
end
