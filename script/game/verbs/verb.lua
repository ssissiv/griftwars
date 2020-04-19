local Verb = class( "Verb", Aspect )

function Verb:init( actor, obj )
	assert( actor == nil )
	self.obj = obj
	self.utility = 0
end

function Verb:SetUtility( utility )
	self.utility = clamp( utility, 0, 100 )
end

function Verb:CalculateTimeSpeed()
	return self.ACT_RATE
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
	return self.actor == verb.actor and self.obj == verb.obj
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

function Verb:CanDo( actor, ... )
	if self.coro then
		return false, "Already executing"
	end

	for i, verb in actor:Verbs() do
		if verb:EqualVerb( self ) then
			return false, "Already executing copy"
		end
	end

	local ok, reason = self:CanInteract( actor, ... )
	if not ok then
		return false, reason
	end

	return true
end

function Verb:CanInteract( actor )
	return (actor or self.actor):IsSpawned()
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

function Verb:DoVerb( actor, ... )
	local ok, reason = self:CanInteract( actor, ... )
	if not ok then
		-- print( "CANT DO", actor, self, reason )
		return false, reason
	end

	if not actor:HasAspect( self ) then
		self.transient = true
		actor:GainAspect( self )
	end

	assert( self:GetOwner() == actor and actor )
	actor:_AddVerb( self )

	self.cancelled = nil
	self.actor = actor
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

	actor:_RemoveVerb( self )

	if self.transient then
		self.transient = nil
		actor:LoseAspect( self )
	end
end

function Verb:IsDoing()
	return self.coro ~= nil
end

function Verb:IsCancelled()
	return self.cancelled == true
end

function Verb:Cancel()
	if not self:IsDoing() then
		return
	end

	self.cancelled = true
	self.cancelled_trace = debug.traceback()

	if self.transient then
		self.transient = nil
		self.actor:LoseAspect( self )
	end

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

	local ok, reason = self:CanInteract( self.actor )
	if not ok then
		self.cant_reason = reason
		self:Cancel()
	else
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
end

function Verb:RenderDebugPanel( ui, panel, dbg )
	panel:AppendTable( ui, self )

	ui.Indent( 20 )
	if self.time_started then
		ui.Text( "Started:" )
		ui.SameLine( 0, 10 )
		Calendar.RenderDatetime( ui, self.time_started, self:GetWorld() )
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
		ui.SameLine( 0, 5 )
		ui.TextColored( 1, 0, 0, 1, "Cancelled" )
	
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
