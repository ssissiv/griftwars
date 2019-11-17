--------------------------------------------------------------------
-- Behaviours schedule Verb evaluation & execution every ONE_HOUR
--    CollectInteractions -> DoVerb

local Behaviour = class( "Aspect.Behaviour", Aspect )

function Behaviour:init()
	self.behaviours = {}
	self.priority = 0

	self:RegisterHandler( AGENT_EVENT.VERB_UNASSIGNED, self.OnVerbUnassigned )
end

function Behaviour:GetName()
	return self.name or self._classname
end

function Behaviour:OnSpawn( world )
	self:ScheduleNextTick()
end

function Behaviour:OnVerbUnassigned( verb )
	if not self.owner:IsBusy() then
		self:OnTickBehaviour()
	end
end

function Behaviour:GetPriority()
	return self.priority
end

function Behaviour:UpdatePriority( world )
	-- for i, behaviour in ipairs( self.behaviours ) do
	--     behaviour:UpdatePriority()
	-- end

	self.priority = self:CalculatePriority( world )
end

function Behaviour:AddBehaviour( behaviour )
	behaviour.owner = self.owner
	table.insert( self.behaviours, behaviour )
end

function Behaviour:AddBehaviours( t )
	for i, behaviour in ipairs( t ) do
		self:AddBehaviour( behaviour )
	end
end

function Behaviour:ScheduleNextTick()
	if self.tick_ev then
		self.owner.world:UnscheduleEvent( self.tick_ev )
	end
	local delta = math.randomGauss( 0.1 * ONE_HOUR, 0.1 * ONE_HOUR, ONE_HOUR / 60 )
	self.tick_ev = self.owner.world:ScheduleFunction( delta, self.OnTickBehaviour, self )
end

function Behaviour.SortBehaviour( a, b )
	return a.priority > b.priority
end

function Behaviour:OnTickBehaviour()
	if self.RunBehaviour then
		self:RunBehaviour()
	end

	self:RunSubBehaviours()

	self:ScheduleNextTick()
end

function Behaviour:CanRun()
	return true
end

function Behaviour:RunSubBehaviours()
	-- First update priorities.
	local world = self:GetWorld()

	for i, behaviour in ipairs( self.behaviours ) do
		behaviour:UpdatePriority( world )
	end

	table.sort( self.behaviours, self.SortBehaviour )

	--
	for i, behaviour in ipairs( self.behaviours ) do
		if behaviour:CanRun() then
			behaviour:RunBehaviour( world )
		end
	end
end

function Behaviour:RenderDebugPanel( ui, panel, dbg )
	ui.PushID( rawstring( self ))
	if ui.TreeNode( self:GetName() ) then
		local world = self:GetWorld()
		ui.Text( loc.format( "Priority: {1}", self.priority ))
		if self.tick_ev then
			ui.Text( "Scheduled:" )
			ui.SameLine( 0, 10 )
			local txt = Calendar.FormatDuration( self.tick_ev.when - world:GetDateTime() )
			ui.TextColored( 0, 1, 1, 1, txt )
		end

		for i, behaviour in ipairs( self.behaviours ) do
			behaviour:RenderDebugPanel( ui, panel, dbg )
		end
		ui.TreePop()
	end
	ui.PopID()
end

function Behaviour:__tostring()
	return string.format( "[%s]", self._classname )
end



