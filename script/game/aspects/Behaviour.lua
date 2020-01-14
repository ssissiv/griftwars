--------------------------------------------------------------------
-- Manages a prioritized list of Verbs

local Behaviour = class( "Aspect.Behaviour", Aspect )

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
	self:ScheduleNextTick( 0 )

	self:RegenerateVerbs()
end

function Behaviour:RegenerateVerbs()
	table.clear( self.verbs )

	for i, aspect in self.owner:Aspects() do
		if is_instance( aspect, Verb ) and aspect.UpdatePriority then
			table.insert( self.verbs, aspect )
		end
	end
end

function Behaviour:OnAspectsChanged( event_name, owner, aspect )

	if is_instance( aspect, Verb ) and aspect.UpdatePriority then
		if event_name == ENTITY_EVENT.ASPECT_LOST then
			table.arrayremove( self.verbs, aspect )
		elseif event_name == ENTITY_EVENT.ASPECT_GAINED then
			table.insert( self.verbs, aspect )
		end
	end
end

function Behaviour:OnVerbUnassigned( event_name, owner, verb )
	self:ScheduleNextTick( 0 )
	self.scheduled_reason = verb
end

function Behaviour:ScheduleNextTick( delta )
	if delta == nil then
		delta = math.randomGauss( 0.1 * ONE_HOUR, 0.1 * ONE_HOUR, ONE_HOUR / 60 )
	end
	if self.tick_ev then
		self.owner.world:RescheduleEvent( self.tick_ev, delta )
	else
		self.tick_ev = self.owner.world:ScheduleFunction( delta, self.OnTickBehaviour, self )
	end
end

function Behaviour.SortVerbs( a, b )
	return a.priority > b.priority
end

function Behaviour:OnTickBehaviour()
	
	self:UpdatePriorities()

	local active_verb
	for i, verb in ipairs( self.verbs ) do
		if not active_verb then
			if self.owner:IsDoing( verb ) then
				active_verb = verb

			elseif verb:CanInteract( self.owner ) then
				self.owner:DoVerbAsync( verb )
				active_verb = verb
			end

		else
			if self.owner:IsDoing( verb ) then
				self:GetWorld():Log( "{1} aborts {2} (doing {3})", self.owner, verb, active_verb )
				print( "CANCEL", self.owner, verb, ", now doing ", active_verb )
				verb:Cancel()
			end
		end
	end

	self:ScheduleNextTick()
end

function Behaviour:UpdatePriorities()
	-- First update priorities.
	local world = self:GetWorld()

	for i, verb in ipairs( self.verbs ) do
		if verb.UpdatePriority then
			verb.priority = verb:UpdatePriority( self.owner, verb.priority ) or -1
		end
	end

	table.sort( self.verbs, self.SortVerbs )
end

function Behaviour:RenderDebugPanel( ui, panel, dbg )
	local world = self:GetWorld()

	if self.scheduled_reason then
		ui.TextColored( 1, 0, 0, 1, "Scheduled Due To:")
		ui.SameLine( 0 ,10 )
		panel:AppendTable( ui, self.scheduled_reason )
	end

	if self.tick_ev then
		ui.Text( "Scheduled:" )
		ui.SameLine( 0, 10 )
		local txt = Calendar.FormatDuration( self.tick_ev.when - world:GetDateTime() )
		ui.TextColored( 0, 1, 1, 1, txt )
	end

	ui.Columns( 3 )
	for i, verb in ipairs( self.verbs ) do
		panel:AppendTable( ui, verb )
		ui.NextColumn()

		ui.Text( tostring(verb.priority) )
		ui.NextColumn()

		if self.owner:IsDoing( verb ) then
			ui.Text( "**" )
		end
		ui.NextColumn()
	end
	ui.Columns( 1 )
end

function Behaviour:__tostring()
	return string.format( "[%s]", self._classname )
end



