--------------------------------------------------------------------
-- Manages a prioritized list of Verbs
local Behaviour = class( "Aspect.Behaviour", Aspect )

Behaviour.TABLE_KEY = "behaviour"

Behaviour.event_handlers =
{
	[ AGENT_EVENT.DIED ] = function( self, event_name, agent, ... )
		agent:LoseAspect( self )
	end,
}

function Behaviour:init()
	self.verbs = {}

	self:RegisterHandler( AGENT_EVENT.VERB_UNASSIGNED, self.OnVerbUnassigned )
	self:RegisterHandler( ENTITY_EVENT.ASPECT_GAINED, self.OnAspectsChanged )
	self:RegisterHandler( ENTITY_EVENT.ASPECT_LOST, self.OnAspectsChanged )
end

function Behaviour:GetName()
	return self.name or self._classname
end

function Behaviour:OnSpawn( world )
	Aspect.OnSpawn( self, world )

	self:ScheduleNextTick( 0, "on-spawn" )

	self:RegenerateVerbs()
end

function Behaviour:OnDespawn()
	if self.tick_ev then
		self:GetWorld():UnscheduleEvent( self.tick_ev )
		self.tick_ev = nil
	end
	Aspect.OnDespawn( self )
end


function Behaviour:RegenerateVerbs()
	table.clear( self.verbs )

	for i, aspect in self.owner:Aspects() do
		if is_instance( aspect, Verb ) and aspect.CalculateUtility then
			table.insert( self.verbs, aspect )
		end
	end
end

function Behaviour:OnAspectsChanged( event_name, owner, aspect )
	if is_instance( aspect, Verb ) and aspect.CalculateUtility then
		if event_name == ENTITY_EVENT.ASPECT_LOST then
			table.arrayremove( self.verbs, aspect )
			if self:GetWorld() then
				self:ScheduleNextTick( 0, tostring(aspect).." lost" )
			end
		elseif event_name == ENTITY_EVENT.ASPECT_GAINED then
			table.insert( self.verbs, aspect )
			if self:GetWorld() then
				self:ScheduleNextTick( 0, tostring(aspect).." gained" )
			end
		end

	elseif is_instance( aspect, Aspect.Puppet ) then
		if event_name == ENTITY_EVENT.ASPECT_LOST then
			self:ScheduleNextTick( 0, "puppet changed" )
		else
			if self.tick_ev then
				self:GetWorld():UnscheduleEvent( self.tick_ev )
				self.tick_ev = nil
			end
		end
	end
end

function Behaviour:OnVerbUnassigned( event_name, owner, verb )
	if not self.ticking then
		self:ScheduleNextTick( 0, tostring(verb).." unassigned" )
	end
end

function Behaviour:ScheduleNextTick( delta, reason )
	if self.owner:IsPuppet() then
		return
	end

	local world = self:GetWorld()
	if delta and self.tick_ev then
		-- Reschedule: but only if we're rescheduling to an earlier time.
		if self.tick_ev.trigger_time or delta < world:GetEventTimeLeft( self.tick_ev ) then
			world:UnscheduleEvent( self.tick_ev )
			self.tick_ev = world:ScheduleFunction( delta, self.OnTickBehaviour, self, "explicit schedule:"..tostring(delta)..":"..tostring(reason))
			self.tick_reason = reason
		end

	elseif delta == nil and (self.tick_ev == nil or self.tick_ev.trigger_time) then
		-- Reschedule for default processing 'some' time in the next hour.
		-- NOTE: this shouldn't really happen unless verbs are failing for some reason.. probably..
		delta = math.randomGauss( 0.1 * ONE_HOUR, 0.1 * ONE_HOUR, ONE_HOUR / 60 )
		self.tick_ev = world:ScheduleFunction( delta, self.OnTickBehaviour, self, "default scheduled:"..tostring(reason) )
		self.tick_reason = reason

	elseif delta == nil and self.tick_ev then
		-- Nothing to do, alrealdy scheduled.

	else
		-- Nothing scheduled yet, go.
		self.tick_ev = world:ScheduleFunction( delta, self.OnTickBehaviour, self, "explicit schedule:"..tostring(delta)..":"..tostring(reason))
		self.tick_reason = reason
	end
end

function Behaviour:GetHighestPriorityVerb()
	return self.verbs[1]
end

function Behaviour:OnTickBehaviour( reason )

	if self.owner:IsPuppet() then
		return
	end
	
	local now = self:Now()

	-- TODO: why does this assert trigger?  is something awry?  wanna check loops of behaviour ticking.
	-- So: A verb resumes after a yield, this triggers OnTickBehaviour to see if the verb should actually
	-- continue or if something else should take priority.
	-- As long as the verb continues, then all is good.. but then it finishes same tick, causing VERB_UNASSIGNED which
	-- in the same frame obviously requires a re-tick.
	-- assert( self.last_tick == nil or self.last_tick < now,
	-- 	string.format( "%s, active_verb=%s, reason=%s, last_reason=%s, now=%s, tick_ev=%s",
	-- 	tostring(self.owner), tostring(self.active_verb), reason ,self.last_reason,
	-- 	now, --Calendar.FormatTime( now, true ),
	-- 	tostr(self.tick_ev)))

	self.last_tick = now
	self.last_reason = reason
	self.ticking = true

	self:UpdatePriorities()

	local active_verb
	for i, verb in ipairs( self.verbs ) do
		if not active_verb then
			if self.owner:IsDoing( verb ) then
				active_verb = verb

			elseif verb:CanInteract() then
				active_verb = verb
			end

		else
			if self.owner:IsDoing( verb ) then
				-- self:GetWorld():Log( "{1} aborts {2} (doing {3})", self.owner, verb, active_verb )
				-- print( "CANCEL", self.owner, verb, ", now doing ", active_verb )
				verb:Cancel( "behaviour")
			end
		end
	end

	self.active_verb = active_verb
	
	if not active_verb then
		-- no verb found, so I guess chill until maybe there is one.
		self:ScheduleNextTick( nil, reason )

	elseif active_verb and not self.owner:IsDoing( active_verb ) then
		local ok, reason = self.owner:DoVerbAsync( active_verb )
		if not self.owner:IsDoing( active_verb ) then
			-- Verb was valid, but is either an insta-complete or perhaps something was not right during processing.
			-- Insta-complete verbs are considered illegal (just call a damn function) and they're more a sign that
			-- a verb's conditions weren't properly validated.
			-- assert( active_verb:IsCancelled() ) -- An insta-complete verb is bad, just make a function.
			print( "Complete immediately", self.owner, active_verb, active_verb:IsCancelled(), "ok:", ok, reason )
			print( "\t", self.tick_reason )
			self:ScheduleNextTick( nil, reason )
		end
	end

	self.ticking = nil
end

function Behaviour:UpdatePriorities()
	-- First update priorities.
	local world = self:GetWorld()

	for i, verb in ipairs( self.verbs ) do
		if verb.CalculateUtility then
			if not verb:IsDoing() and not verb:CanDo() then
				verb:SetUtility( -1 )
			else
				verb:SetUtility( verb:CalculateUtility())
			end
		end
	end

	table.sort( self.verbs, Verb.SortByUtility )
end

function Behaviour:RenderDebugPanel( ui, panel, dbg )
	local world = self:GetWorld()

	if self.last_tick then
		ui.TextColored( 0.8, 0.8, 0.8, 1, loc.format( "Last tick: {1#duration}", self.last_tick - world:GetDateTime()))
	end

	if self.tick_reason then
		ui.TextColored( 1, 0, 0, 1, "Scheduled Due To:")
		ui.SameLine( 0 ,10 )
		panel:AppendTable( ui, self.tick_reason )
	end

	if self.tick_ev and not self.tick_ev.trigger_time then
		ui.Text( "Tick in:" )
		ui.SameLine( 0, 10 )
		local txt = Calendar.FormatDuration( self.tick_ev.when - world:GetDateTime() )
		ui.TextColored( 0, 1, 1, 1, txt )
	end
	if ui.Button( "Schedule Now" ) then
		self:ScheduleNextTick(0, "debug")
	end

	ui.Columns( 3 )
	for i, verb in ipairs( self.verbs ) do
		panel:AppendTable( ui, verb )
		ui.NextColumn()

		ui.Text( tostring(verb.utility) )
		ui.NextColumn()

		if self.owner:IsDoing( verb ) then
			ui.Text( "**" )
		end
		ui.NextColumn()
	end
	ui.Columns( 1 )
end


