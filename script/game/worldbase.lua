local WorldBase = class( "WorldBase", Entity )

function WorldBase:init()
	self.datetime = 0
	self.debug_world_speed = 1.0
	self.next_id = 100

	self:ListenForAny( self, self.OnWorldEvent )
	self.scheduled_events = {}

	self.buckets = {}
	self.entities = {}
	self.pause = {}
end

function WorldBase:SetNexus( nexus )
	self.nexus = nexus
end

function WorldBase:GenerateID()
	self.next_id = self.next_id + 1
	return self.next_id
end

function WorldBase:IsGameOver()
	return false
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

function WorldBase:RescheduleEvent( ev, delta )
	assert( delta >= 0 or error( string.format( "Rescheduling in the past: %s with delta %d", tostr(ev), delta )))
	ev.cancel = nil
	ev.when = self.datetime + delta
	table.arrayremove( self.scheduled_events, ev )
	table.binsert( self.scheduled_events, ev, CompareScheduledEvents )
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
		table.remove( self.scheduled_events, 1 ) -- TODO: this is terrible, rewrite as a linked list

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
		return table.arraycontains( self.pause, pause_type )
	else
		return #self.pause > 0 or self:IsGameOver()
	end
end

function WorldBase:SetDebugTimeSpeed( speed )
	self.debug_world_speed = speed
end

function WorldBase:GetDateTime()
	return self.datetime
end

function WorldBase:AdvanceTime( dt )
	self.datetime = self.datetime + dt
	self:CheckScheduledEvents()
end

function WorldBase:SpawnEntity( ent )
	ent:OnSpawn( self )
	assert( not table.contains( self.entities, ent ))
	table.insert( self.entities, ent )
	return ent
end

function WorldBase:DespawnEntity( ent )
	ent:OnDespawn( self )
	table.arrayremove( self.entities, ent )
end

function WorldBase:CreateBucketByAspect( aspect )
	assert( is_class( aspect, Aspect ))
	for i, ent in ipairs( self.entities ) do
		if ent:HasAspect( aspect ) then
			self:RegisterToBucket( aspect, ent )
		end
	end

	return self.buckets[ aspect ]
end

function WorldBase:CreateBucketByClass( class )
	assert( is_class( class ))
	for i, ent in ipairs( self.entities ) do
		if is_instance( ent, class ) then
			self:RegisterToBucket( class, ent )
		end
	end

	return self.buckets[ class ]
end

function WorldBase:RegisterToBucket( key, obj )
	assert( is_class( key ))
	local bucket = self.buckets[ key ]
	if bucket == nil then
		bucket = {}
		self.buckets[ key ] = bucket
	end
	table.insert_unique( bucket, obj )
end

function WorldBase:UnregisterFromBucket( key, obj )
	local bucket = self.buckets[ key ]
	table.arrayremove( bucket, obj )
end

function WorldBase:RemoveBucket( key )
	self.buckets[ key ] = nil
end

function WorldBase:Bucket( key )
	return pairs( self.buckets[ key ] or table.empty )
end

function WorldBase:GetBucket( key )
	return self.buckets[ key ]
end

function WorldBase:CalculateTimeElapsed( dt )
	return dt * WALL_TO_GAME_TIME * self.debug_world_speed
end

function WorldBase:UpdateWorld( dt )
	if not self:IsPaused() then
		local world_dt = self:CalculateTimeElapsed( dt )
		self:AdvanceTime( world_dt )

		if self.OnUpdateWorld then
			self:OnUpdateWorld( dt, world_dt )
		end
	end
end


