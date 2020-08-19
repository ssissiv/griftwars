local Verb = class( "Verb", Aspect )

Verb.event_handlers =
{
	[ AGENT_EVENT.DIED ] = function( self, event_name, agent, ... )
		if agent:HasAspect( self ) then
			agent:LoseAspect( self )
		else
			self:Cancel( "died" )
		end
	end,
}

function Verb:init( actor, obj )
	assert( actor == nil or is_instance( actor, Agent ))
	assert( not obj )
	self.actor = actor
	self.utility = 0
end

function Verb:Clone()
	local clone = setmetatable( table.shallowcopy( self ), self._class )
	return clone
end

function Verb:SetUtility( utility )
	self.utility = clamp( utility, 0, 100 )
end

function Verb:GetUtility()
	return self.utility
end

function Verb.SortByUtility( a, b )
	return a.utility > b.utility
end

function Verb:CalculateTimeElapsed( dt )
	if self.yield_type == "instant" then
		-- Instant
		local now = self.world:GetDateTime()
		local duration = self.yield_value - now
		assert( duration >= 0 )
		return duration / WALL_TO_GAME_TIME

	elseif self.yield_type == "wall" then
		return dt * self.yield_value

	elseif self.yield_type == "rate" then
		return dt * self.yield_value

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
	return self.target or self.obj -- Eew, override?
end

function Verb:EqualVerb( verb )
	if verb._class ~= self._class then
		return false
	end
	for k, v in pairs( self ) do
		if v ~= verb[k] then
			return false
		end
	end
	return true
end

function Verb:GetOwner()
	local parent = self.parent
	while self.owner == nil and parent do
		parent = parent.parent
	end
	return self.owner
end

function Verb:OnLoseAspect( owner )
	self:Cancel( "lose aspect" )
	Aspect.OnLoseAspect( self, owner )
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

function Verb:GetActDesc()
    return self.act_desc or tostring(self)
end

function Verb:CheckDC( actor, target )
	local dc = self:CalculateDC( actor, target )
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

-- CanInitiate
function Verb:CanDo()
	local actor = self.actor
	assert( is_instance( actor, Agent ), tostring(actor))

	if self.coro then
		return false, "Already executing"
	end

	-- for i, verb in actor:Verbs() do
	-- 	if verb:EqualVerb( self ) then
	-- 		return false, "Already executing copy"
	-- 	end
	-- end

	if not actor:GetLocation() then
		return false, "In limbo"
	end

	if self.FLAGS then
		local busy, verb = actor:IsBusy( self.FLAGS )
		if busy then
			return false, "Busy: "..tostring(verb)
		end
	end

	local ok, reason = self:CanInteract()
	if not ok then
		return false, reason
	end

	return true
end

-- CanInitiateOrContinue
function Verb:CanInteract()
	if not self.actor then
		return false, "No actor"
	end
	if not self.actor:IsSpawned() or self.actor:IsDead() then
		return false, "Despawned or dead actor"
	end
	if self.actor.world:IsNotIdlePaused() then
		return false, "Paused"
	end

	if self.reqs then
		local ok, reason = self.reqs:IsSatisfied( self.actor )
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

function Verb:DoChildVerb( verb )
	assert( self:IsRunning() )

	if self.cancelled then
		print( self, " attempted to DoChildVerb while cancelled!" )
		print( debug.traceback() )
		return
	end

	local ok, reason = verb:CanDo()
	if not ok then
		return false, reason
	end

	assert( self.child == nil )
	self.child = verb

	assert( verb.parent == nil )
	verb.parent = self

	local result = verb:DoVerb()

	self.child = nil
	verb.parent = nil

	return result
end

function Verb:DoVerb()
	local actor = self.actor
	assert( actor )
	assert( actor:IsDoing( self ), "not doing" )

	if self.event_handlers then
		for event_name, fn in pairs( self.event_handlers ) do
			actor:ListenForEvent( event_name, self, fn )
		end
	end

	self.world = actor.world

	self.error = nil
	self.cancelled = nil
	self.cancelled_trace = nil
	self.cancelled_frame = nil
	self.cancelled_time = nil
	self.cancelled_reason = nil

	self.coro = coroutine.running()
	assert( self.coro )
	self.time_started = actor.world:GetDateTime()

	-- actor.world:Log( "{1} begins {2} at {3}", actor, self, actor.location )`

	self:Interact()

	self:Cleanup()

	return true
end

function Verb:Cleanup()
	assert( self.yield_ev == nil )
	assert( self.yield_duration == nil )
	assert( self.child == nil )

	self.coro = nil
	self.time_finished = self.actor.world:GetDateTime()

	self.actor:RemoveListener( self )
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

function Verb:Cancel( reason )
	if not self:IsDoing() then
		return
	end

	-- print ( "CANCEL", self, self.actor, self.coro and coroutine.status( self.coro ), debug.traceback())

	if self.cancelled then
		local txt = loc.format( "Already Cancelled!\nFrame: {1} / Cancelled Frame: {2}\nCancelled Trace:\n{3}",
			GetFrame(), self.cancelled_frame, self.cancelled_trace )
		self:ShowError( self.coro, txt )
	end

	self.cancelled = true
	self.cancelled_trace = debug.traceback()
	self.cancelled_time = self.actor.world:GetDateTime()
	self.cancelled_frame = GetFrame()
	self.cancelled_reason = reason

	if self.child then
		assert( self.yield_ev == nil ) -- We cannot be the yielding Verb if a child is running.
		self.child:Cancel( "parent cancelled: " ..tostring(reason) )

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
	assert( duration > 0 or how == "instant" )

	if self.cancelled then
		-- print( self, " attempted to yield while cancelled!" )
		-- print( debug.traceback() )
		return
	end

	self.yield_type = how

	if how == "rate" then
		-- Time is sped up by a factor of ACT_RATE
		self.yield_value = act_rate

	elseif how == "wall" then
		-- Time is sped up so that duration will pass in 'act_rate' wall time.
		-- (dt / self.ACT_RATE) * self.ACT_DURATION / WALL_TO_GAME_TIME
		self.yield_value = duration / (act_rate * WALL_TO_GAME_TIME)

	elseif how == "instant" then
		-- Time will advance by duration, instantly.
		self.yield_value = self.world:GetDateTime() + duration

	else
		self.yield_value = nil
	end

	self.yield_ev = self.actor.world:ScheduleFunction( duration, self.Resume, self, coroutine.running() )
	self.yield_duration = duration
	local result = coroutine.yield()

	self.yield_value = nil
	self.yield_type = nil

	return result
end

function Verb:YieldForInterrupt( agent, msg )
	if agent:IsPuppet() then --and not self.world:IsPaused() then
		self.world:ScheduleInterrupt( 0, msg )
		self:YieldForTime( ONE_SECOND, "instant" )
	end	
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
		local ok, reason = self:CanInteract()
		if not ok then
			self:Cancel( reason )


		-- Behaviour might also cancel.
		elseif self.actor.behaviour then
			self.actor.behaviour:OnTickBehaviour( tostring(self).. " finished" )
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

	if self.cancelled and self.actor:IsDoing( self ) and not self.error then
		self:ShowError( coro, "verb didnt respect cancellation" )
		-- What now? Forcibly remove from actor? etc.?
	end
end

function Verb:ShowError( coro, msg )
	self:GetWorld():SetPause( PAUSE_TYPE.ERROR )
	print( "ShowError", self, coro and coroutine.status( coro ), "\n", msg )
	local trace = debug.traceback()
	self.error = msg

	DBG( function( node, ui, panel )
		if self.coro_dbg == nil then
			self.coro_dbg = DebugCoroutine( coro )
		else
			self.coro_dbg:SetCoro( coro )
		end

		panel:AppendTable( ui, self )
		panel:AppendTable( ui, self.actor )
		ui.Separator()

		ui.TextColored( 1, 0, 0, 1, tostring(msg) )
		if ui.TreeNode( "traceback" ) then
			ui.Text( trace )
			ui.TreePop()
		end
		ui.Spacing()

		self.coro_dbg:RenderPanel( ui, panel )
		return true
	end )
end


function Verb:RenderDebugPanel( ui, panel, dbg )
	ui.PushID( rawstring( self ))

	panel:AppendTable( ui, self )

	if self.error then
		ui.TextColored( 1, 0, 0, 1, "Error: " ..tostring(self.error))
	end

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
		ui.TextColored( 1, 0, 0, 1, loc.format( "Cancelled ({1})", self.cancelled_reason or "?" ))
		if self.cancelled_time then
			ui.SameLine( 0, 10 )
			Calendar.RenderDatetime( ui, self.cancelled_time, self:GetWorld() )
		end
		if ui.IsItemHovered() then
			ui.SetTooltip( tostring(self.cancelled_trace) )
		end

	
	elseif self:IsDoing() then
		if coroutine.status( self.coro ) == "dead" then
			if ui.Button( "Cleanup" ) then
				self:Cleanup()
			end

		elseif ui.Button( "Cancel" ) then
			self:Cancel( "debug" )
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
	if self.actor then
		return string.format( "<%s:%s>", self._classname, tostring(self.actor))
	else
		return string.format( "<%s>", self._classname )
	end
end
