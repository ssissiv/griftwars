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
	self:ClearAgenda()
	self.last_agenda = self:GetWorld():GetDateTime()
	self.owner:BroadcastEvent( AGENT_EVENT.CALC_AGENDA, self )

	local hour = Calendar.GetHour( self.owner.world:GetDateTime() )
	for i, task in ipairs( self.tasks ) do
		if hour >= task.start_time and hour <= task.end_time then
			if task.verb:CanInteract() then
				self.owner:DoVerb( task.verb )
				break
			end
		end
	end
end

function Agenda:ScheduleTaskForAgenda( verb, start_time, end_time )
	assert( is_instance( verb, Verb ))
	local task = {
		verb = verb,
		start_time = start_time,
		end_time = end_time
	}
	table.insert( self.tasks, task )
end


function Agenda:ClearAgenda()
	table.clear( self.tasks )
end
