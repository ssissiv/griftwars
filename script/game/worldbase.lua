local WorldBase = class( "WorldBase" )

function WorldBase:init()
	self.datetime = 0

	self.events = EventSystem()
	self.events:ListenForAny( self, self.OnWorldEvent )
	self.scheduled_events = {}

	self.rooms = {}
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
	assert( delta > 0 or error( string.format( "Scheduling in the past: %s with delta %d", event_name, delta )))
	local ev = { when = self.world_tick + delta, event_name, ... }
	table.binsert( self.scheduled_events, ev, CompareScheduledEvents )
	return ev
end

function WorldBase:SchedulePeriodicEvent( delta, event_name, ... )
	local ev = self:ScheduleEvent( delta, event_name, ... )
	ev.period = delta
	return ev
end

function WorldBase:UnscheduleEvent( ev )
	ev.cancel = true
end

function WorldBase:UpdateWorld( dt )
end


