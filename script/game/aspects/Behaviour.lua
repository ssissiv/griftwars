--------------------------------------------------------------------
-- Manages a prioritized list of Verbs

local Behaviour = class( "Aspect.Behaviour", Aspect )

function Behaviour:init()
	self.verbs = {}

	self:RegisterHandler( AGENT_EVENT.VERB_UNASSIGNED, self.OnVerbUnassigned )
end

function Behaviour:GetName()
	return self.name or self._classname
end

function Behaviour:OnSpawn( world )
	self:ScheduleNextTick( 0 )
end

function Behaviour:RegisterVerb( verb )
	local t =
	{
		verb = verb,
		priority = 0,
	}
	table.insert( self.verbs, t )
end

function Behaviour:RegisterVerbs( verbs )
	for i, verb in ipairs( verbs ) do
		self:RegisterVerb( verb )
	end
end

function Behaviour:OnVerbUnassigned( verb )
	self:ScheduleNextTick( ONE_MINUTE ) -- uh, this granularity is kinda awkward...
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
	for i, t in ipairs( self.verbs ) do
		if not active_verb then
			if self.owner:IsDoing( t.verb ) then
				active_verb = t.verb

			elseif t.verb:CanInteract( self.owner ) then
				self.owner:DoVerbAsync( t.verb )
				active_verb = t.verb
			end

		else
			if self.owner:IsDoing( t.verb ) then
				t.verb:Cancel()
			end
		end
	end

	self:ScheduleNextTick()
end

function Behaviour:UpdatePriorities()
	-- First update priorities.
	local world = self:GetWorld()

	for i, t in ipairs( self.verbs ) do
		if t.verb.UpdatePriority then
			t.priority = t.verb:UpdatePriority( self.owner, t.priority ) or -1
		end
	end

	table.sort( self.verbs, self.SortVerbs )
end

function Behaviour:RenderDebugPanel( ui, panel, dbg )
	local world = self:GetWorld()

	if self.tick_ev then
		ui.Text( "Scheduled:" )
		ui.SameLine( 0, 10 )
		local txt = Calendar.FormatDuration( self.tick_ev.when - world:GetDateTime() )
		ui.TextColored( 0, 1, 1, 1, txt )
	end

	ui.Columns( 3 )
	for i, t in ipairs( self.verbs ) do
		panel:AppendTable( ui, t.verb )
		ui.NextColumn()

		ui.Text( tostring(t.priority) )
		ui.NextColumn()

		if self.owner:IsDoing( t.verb ) then
			ui.Text( "**" )
		end
		ui.NextColumn()
	end
	ui.Columns( 1 )
end

function Behaviour:__tostring()
	return string.format( "[%s]", self._classname )
end



