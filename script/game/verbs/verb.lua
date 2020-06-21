local Verb = class( "Verb", Aspect )

Verb.event_handlers =
{
	[ AGENT_EVENT.DIED ] = function( self, event_name, agent, ... )
		agent:LoseAspect( self )
	end,
}

function Verb:init( actor, obj )
	assert( actor == nil )
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

function Verb:AddChildVerb( verb )
	if self.children == nil then
		self.children = {}
	end
	table.insert( self.children, verb )

	assert( verb.parent == nil )
	verb.parent = self

	return verb
end

function Verb:RemoveChildVerb( verb )
	assert( verb.parent == self )
	table.arrayremove( self.children, verb )
	verb.parent = nil
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

function Verb:GetRoomDesc( viewer )
	local desc = self:GetDesc( viewer )

	if self.GetDuration then
		return loc.format( "{1} ({2})", desc, Calendar.FormatDuration( self:GetDuration() ))
	else
		return desc
	end
end

function Verb:CalculateDC( actor, target )
	local dc, details = self.DC
	if dc == nil then
		return
	end
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

function Verb:CheckDC( actor, target )
	local dc = self:CalculateDC( actor, target )
	local roll = math.random( 0, 20 )
	return roll >= dc, roll
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

	return true
end

function Verb:GetDesc()
	return self._classname
end

function Verb:GetShortDesc( viewer )
end

function Verb:DidWithinTime( actor, dt )
	if self.time_finished then
		return actor.world:GetDateTime() - self.time_finished <= dt
	end

	return false
end

-- Involves this acting agent in the verb.
function Verb:AttachActor( actor )
	actor:_AddVerb( self )

	assert( self.actors, self._classname )
	table.insert( self.actors, actor )

	if self.event_handlers then
		for event_name, fn in pairs( self.event_handlers ) do
			actor:ListenForEvent( event_name, self, fn )
		end
	end

	return true
end


function Verb:DoVerb( actor, ... )
	local ok, reason = self:CanDo( actor, ... )
	if not ok then
		return false, reason
	end

	self:AttachActor( actor )

	self.actor = actor
	self.world = actor.world
	self.cancelled = nil
	self.coro = coroutine.running()
	assert( self.coro )
	self.time_started = actor.world:GetDateTime()

	-- actor.world:Log( "{1} begins {2} at {3}", actor, self, actor.location )`

	self:Interact( actor, ... )

	if self.yield_ev then
		actor.world:UnscheduleEvent( self.yield_ev )
		self.yield_ev = nil
	end

	self.yield_duration = nil
	self.coro = nil
	self.time_finished = actor.world:GetDateTime()

	for i, actor in ipairs( self.actors ) do
		actor:RemoveListener( self )
		actor:_RemoveVerb( self )
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

	assert( not self.cancelled )
	self.cancelled = true
	self.cancelled_trace = debug.traceback()
	self.cancelled_time = self.actor.world:GetDateTime()

	-- print ( "CANCEL", self, self.actor, debug.traceback())
	if self.yield_ev then
		self.actor.world:UnscheduleEvent( self.yield_ev )
		self.actor.world:TriggerEvent( self.yield_ev )
	end

	if self.children then
		for i, child in ipairs( self.children ) do
			child:Cancel()
		end
	end

	if self.OnCancel then
		self:OnCancel()
	end
end

function Verb:CanCancel()
	return true
end

function Verb:GetActingTime()
	local time_left = self.yield_ev.when - self.actor.world:GetDateTime()
	return time_left, self.yield_duration
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
		print( self, " attempted to yield while cancelled!" )
		print( debug.traceback() )
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

	elseif self.children then
		for i, child in ipairs( self.children ) do
			if child:Unyield() then
				return true
			end
		end
	end

	return false
end

function Verb:Resume( coro )
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
		self:GetWorld():TogglePause( PAUSE_TYPE.ERROR )
		DBG( function( node, ui, panel )
			if self.coro_dbg == nil then
				self.coro_dbg = DebugCoroutine( coro )
			end

			panel:AppendTable( ui, self )
			ui.SameLine( 0, 10 )
			panel:AppendTable( ui, self.actor )
			ui.Separator()

			ui.TextColored( 1, 0, 0, 1, tostring(result) )
			ui.Spacing()

			self.coro_dbg:RenderPanel( ui, panel )

			ui.NewLine()
			if ui.Button( "Resume" ) then
				self:GetWorld():TogglePause( PAUSE_TYPE.ERROR )
			end
		end )

	elseif coroutine.status( coro ) == "suspended" then
		-- Waiting.  Note that even if we are cancelled, the coro is still valid if we are part of a parent verb.
		assert_warning( not self.cancelled or self.parent ~= nil, tostring(self))
		--assert( self.yield_ev ) -- A child verb might have yielded, not us.
	else
		-- Done!
		-- print( "DONE", self, coroutine.status(coro))
	end
end

function Verb:RenderDebugPanel( ui, panel, dbg )
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
	ui.Unindent( 20 )
end

function Verb:__tostring()
	if self.obj then
		return string.format( "<%s : %s>", self._classname, tostring(self.obj))
	else
		return string.format( "<%s>", self._classname )
	end
end
