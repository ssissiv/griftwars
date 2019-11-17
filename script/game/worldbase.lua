local WorldBase = class( "WorldBase" )

function WorldBase:init()
	self.datetime = 0
	self.world_speed = 1.0

	self.events = EventSystem()
	self.events:ListenForAny( self, self.OnWorldEvent )
	self.scheduled_events = {}

	self.pause = {}
end

function WorldBase:SetNexus( nexus )
	self.nexus = nexus
end

function WorldBase:IsGameOver()
	return false
end

function WorldBase:ListenForAny( listener, fn, priority )
	self.events:ListenForAny( listener, fn, priority )
end

function WorldBase:ListenForEvent( event, listener, fn, priority )
	self.events:ListenForEvent( event, listener, fn, priority )
end

function WorldBase:ListenForEvent( event, listener, fn, priority )
	self.events:ListenForEvent( event, listener, fn, priority )
end

function WorldBase:RemoveListener( listener )
	self.events:RemoveListener( listener )
end

function WorldBase:BroadcastEvent( event_name, ... )
	self.events:BroadcastEvent( event_name, ... )
end

function WorldBase:OnWorldEvent( event_name, ... )
	if event_name == WORLD_EVENT.LOG then
		print( "WORLD_EVENT.LOG:", ... )
	end
end

local function CompareScheduledEvents( ev1, ev2 )
	return ev1.when < ev2.when
end

function WorldBase:ScheduleEvent( delta, event_name, ... )
	assert( delta >= 0 or error( string.format( "Scheduling in the past: %s with delta %d", event_name, delta )))
	assert( type(event_name) == "string" )
	local ev = { when = self.datetime + delta, event_name, ... }
	table.binsert( self.scheduled_events, ev, CompareScheduledEvents )
	return ev
end

function WorldBase:ScheduleFunction( delta, fn, ... )
	assert( delta >= 0 or error( string.format( "Scheduling in the past: %s with delta %d", type(fn), delta )))
	assert( type(fn) == "function" )
	local ev = { when = self.datetime + delta, fn, ... }
	table.binsert( self.scheduled_events, ev, CompareScheduledEvents )
	return ev
end

function WorldBase:SchedulePeriodicEvent( delta, event_name, ... )
	local ev = self:ScheduleEvent( delta, event_name, ... )
	ev.period = delta
	return ev
end

function WorldBase:SchedulePeriodicFunction( delta, fn, ... )
	local ev = self:ScheduleFunction( delta, fn, ... )
	ev.period = delta
	return ev
end

function WorldBase:UnscheduleEvent( ev )
	ev.cancel = true
end

function WorldBase:TriggerEvent( ev )
	if type( ev[1] ) == "function" then
		local fn = ev[1]
		fn( table.unpack( ev, 2 ))
	else
		self:BroadcastEvent( table.unpack( ev ) )
	end
end

function WorldBase:GetEventTimeLeft( ev )
	return math.max( 0, ev.when - self.datetime )
end

function WorldBase:CheckScheduledEvents()
	-- Broadcast any scheduled events.
	local ev = self.scheduled_events[ 1 ]

	while ev and ev.when <= self.datetime do
		table.remove( self.scheduled_events, 1 )

		if not ev.cancel then
			self:TriggerEvent( ev )
		end

		if not ev.cancel then
			if ev.period then
				ev.when = self.datetime + ev.period
				table.binsert( self.scheduled_events, ev, CompareScheduledEvents )
			end
		end

		ev = self.scheduled_events[1]
	end
end


function WorldBase:TogglePause( pause_type )
	pause_type = pause_type or PAUSE_TYPE.DEBUG
	assert( IsEnum( pause_type, PAUSE_TYPE ))
	local idx = table.arrayfind( self.pause, pause_type )
	if idx then
		table.remove( self.pause, idx )
	else
		table.insert( self.pause, pause_type )
	end
end

function WorldBase:IsPaused( pause_type )
	if pause_type then
		return table.arraycontains( pause_type )
	else
		return #self.pause > 0 or self:IsGameOver()
	end
end

function WorldBase:SetWorldSpeed( speed )
	self.world_speed = speed
end

function WorldBase:GetWorldSpeed()
	return self.world_speed
end

function WorldBase:GetDateTime()
	return self.datetime
end

function WorldBase:UpdateWorld( dt )
	if not self:IsPaused() then
		local world_dt = dt * WALL_TO_GAME_TIME * self.world_speed
		self.datetime = self.datetime + world_dt
		self:CheckScheduledEvents()

		if self.OnUpdateWorld then
			self:OnUpdateWorld( dt, world_dt )
		end
	end
end


