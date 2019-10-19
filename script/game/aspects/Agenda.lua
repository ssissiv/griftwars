-- An Agenda is a prioritized list of tasks that schedule Verbs according to the time of day.
local Agenda = class( "Aspect.Agenda", Aspect )

function Agenda:init()
	self.tasks = {}
	self:RegisterHandler( AGENT_EVENT.VERB_UNASSIGNED, self.OnVerbUnassigned )
	self:RegisterHandler( WORLD_EVENT.START, self.OnStart )
end

function Agenda:OnStart( world )
	self:CalculateAgenda()
end

function Agenda:OnVerbUnassigned( verb )
	if not self.owner:IsBusy() then
		self:CalculateAgenda()
	end
end

function Agenda:CalculateAgenda()
	-- self:ClearAgenda()
	self.owner:AssertNotBusy()
	assert( not self.owner:IsBusy() )

	local world = self:GetWorld()
	self.last_agenda = world:GetDateTime()
	self.next_agenda = nil
	self.owner:BroadcastEvent( AGENT_EVENT.CALC_AGENDA, self )

	local now = world:GetDateTime()
	local tod = Calendar.GetTimeOfDay( now )
	local next_task, min_time_to_task
	for i, task in ipairs( self.tasks ) do
		if tod >= task.start_time and tod < task.end_time then
			if task.verb:CanInteract() then
				task.verb:SetEndTime( task.end_time )
				self.owner:DoVerb( task.verb )
				next_task = nil
				break
			end
		end

		local start_datetime = task.start_time + (now - tod)
		if start_datetime < now then
			start_datetime = start_datetime + ONE_DAY
		end
		local time_to_task = start_datetime - now
		if next_task == nil or time_to_task < min_time_to_task then
			next_task, min_time_to_task = task, time_to_task
		end
	end

	-- ok, schedule for the next verb.
	if next_task then
		assert( self.next_agenda == nil )
		self.next_agenda = self:GetWorld():ScheduleFunction( min_time_to_task, self.CalculateAgenda, self )
	end
end

function Agenda:ScheduleTaskForAgenda( verb, start_time, end_time, source )
	assert( is_instance( verb, Verb ))
	assert( source ~= nil )

	-- First remove any tasks currently assigned by source.
	for i = #self.tasks, 1, -1 do
		local task = self.tasks[ i ]
		if task.source == source then
			table.remove( self.tasks, i )
		end
	end

	local task = {
		verb = verb,
		source = source,
		start_time = start_time,
		end_time = end_time
	}
	table.insert( self.tasks, task )
end


function Agenda:ClearAgenda()
	table.clear( self.tasks )
end
