--------------------------------------------------------------------
-- Manages a prioritized list of Verbs
local Behaviour = class( "Aspect.Behaviour", Aspect )

Behaviour.event_handlers =
{
	[ AGENT_EVENT.KILLED ] = function( self, event_name, agent, ... )
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

	self:ScheduleNextTick( 0 )

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
				self:ScheduleNextTick( 0 )
				self.scheduled_reason = aspect
			end
		elseif event_name == ENTITY_EVENT.ASPECT_GAINED then
			table.insert( self.verbs, aspect )
			if self:GetWorld() then
				self:ScheduleNextTick( 0 )
				self.scheduled_reason = aspect
			end
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
	return a.utility > b.utility
end

function Behaviour:OnTickBehaviour()
	
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

	if active_verb and not self.owner:IsDoing( active_verb ) then
		self.owner:DoVerbAsync( active_verb )
	end

	self:ScheduleNextTick()
end

function Behaviour:UpdatePriorities()
	-- First update priorities.
	local world = self:GetWorld()

	for i, verb in ipairs( self.verbs ) do
		if verb.CalculateUtility then
			verb:SetUtility( verb:CalculateUtility( self.owner ))
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

		ui.Text( tostring(verb.utility) )
		ui.NextColumn()

		if self.owner:IsDoing( verb ) then
			ui.Text( "**" )
		end
		ui.NextColumn()
	end
	ui.Columns( 1 )
end


