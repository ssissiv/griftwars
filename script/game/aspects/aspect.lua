local Aspect = class( "Aspect" )

function Aspect:GetID()
	return self._classname
end

function Aspect:GetWorld()
	local owner = self.owner
	while owner do
		if owner.world then
			return owner.world
		end
		owner = owner.owner
	end
end

function Aspect:OnGainAspect( owner )
	assert( owner )
	assert( self.owner == nil )
	self.owner = owner
	if self.event_handlers then
		for event, fn in pairs( self.event_handlers ) do
			if not IsEnum( event, WORLD_EVENT ) then
				owner:ListenForEvent( event, self, fn )
			end
		end
	end
end

function Aspect:OnSpawn( world )
	if self.event_handlers then
		for event, fn in pairs( self.event_handlers ) do
			if IsEnum( event, WORLD_EVENT ) then
				self.owner.world:ListenForEvent( event, self, fn )
			else
				self.owner:ListenForEvent( event, self, fn )
			end
		end
	end
end

function Aspect:OnLoseAspect( owner )
	self.owner:RemoveListener( self )
	self.owner = nil
end

function Aspect:OnDespawn()
	self.owner.world:RemoveListener( self )

	if self.scheduled_evs then
		for i, ev in ipairs( self.scheduled_evs ) do
			self.owner.world:UnscheduleEvent( ev )
		end
	end
end

function Aspect:SchedulePeriodicFunction( delta, fn, ... )
	local ev = self.owner.world:SchedulePeriodicFunction( delta, fn, self, ... )
	if self.scheduled_evs == nil then
		self.scheduled_evs = {}
	end
	table.insert( self.scheduled_evs, ev )
end

function Aspect:ScheduleFunction( delta, fn, ... )
	local ev = self.world:ScheduleFunction( delta, fn, self, ... )
	if self.scheduled_evs == nil then
		self.scheduled_evs = {}
	end
	table.insert( self.scheduled_evs, ev )
end

function Aspect:RegisterHandler( event, fn )
	assert( type(fn) == "function", event )

	if self.event_handlers == nil then
		self.event_handlers = {}
	end
	self.event_handlers[ event ] = fn
end


function Aspect:__tostring()
	return self._classname
end
