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

	self:ScheduleNextTick( 0, "debug" )

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
	self:ScheduleNextTick( 0, "verb removed" )
end

function Behaviour:ScheduleNextTick( delta, reason )
	if self.owner:IsPuppet() then
		return
	end

	if delta and self.tick_ev then
		if delta < self.owner.world:GetEventTimeLeft( self.tick_ev ) then
			self.owner.world:RescheduleEvent( self.tick_ev, delta )
			self.tick_reason = reason
		end

	elseif delta == nil and self.tick_ev == nil then
		delta = math.randomGauss( 0.1 * ONE_HOUR, 0.1 * ONE_HOUR, ONE_HOUR / 60 )
		self.tick_ev = self.owner.world:ScheduleFunction( delta, self.OnTickBehaviour, self )
		self.tick_reason = reason

	elseif delta == nil and self.tick_ev then
		-- Nothing to do.

	else
		self.tick_ev = self.owner.world:ScheduleFunction( delta, self.OnTickBehaviour, self )
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
	
	self.last_tick = self:GetWorld():GetDateTime()

	self:UpdatePriorities()

	local active_verb
	for i, verb in ipairs( self.verbs ) do
		if not active_verb then
			if self.owner:IsDoing( verb ) then
				active_verb = verb

			elseif verb:CanInteract( self.owner ) then
				active_verb = verb
			end

		else
			if self.owner:IsDoing( verb ) then
				-- self:GetWorld():Log( "{1} aborts {2} (doing {3})", self.owner, verb, active_verb )
				-- print( "CANCEL", self.owner, verb, ", now doing ", active_verb )
				verb:Cancel()
			end
		end
	end

	self.active_verb = active_verb
	
	if active_verb and not self.owner:IsDoing( active_verb ) then
		local ok, reason = self.owner:DoVerbAsync( active_verb )
		if not self.owner:IsDoing( active_verb ) then
			-- Verb was valid, but is either an insta-complete or perhaps something was not right during processing.
			print( "Not doing", self.owner, active_verb, ok, reason, active_verb:IsCancelled() )
		end
	end

	self:ScheduleNextTick( nil, reason )
end

function Behaviour:UpdatePriorities()
	-- First update priorities.
	local world = self:GetWorld()

	for i, verb in ipairs( self.verbs ) do
		if verb.CalculateUtility then
			verb:SetUtility( verb:CalculateUtility( self.owner ))
		end
	end

	table.sort( self.verbs, Verb.SortByUtility )
end

function Behaviour:RenderDebugPanel( ui, panel, dbg )
	local world = self:GetWorld()

	if self.last_tick then
		ui.TextColored( 0.8, 0.8, 0.8, 1, loc.format( "Last scheduled: {1#duration}", self.last_tick - world:GetDateTime()))
	end

	if self.tick_reason then
		ui.TextColored( 1, 0, 0, 1, "Scheduled Due To:")
		ui.SameLine( 0 ,10 )
		panel:AppendTable( ui, self.tick_reason )
	end

	if self.tick_ev then
		ui.Text( "Scheduled:" )
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


