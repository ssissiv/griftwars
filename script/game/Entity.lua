local Entity = class( "Entity" )

function Entity:init()
end

function Entity:ListenForAny( listener, fn, priority )
	self:GetEvents():ListenForAny( listener, fn, priority )
end

function Entity:ListenForEvent( event, listener, fn, priority )
	self:GetEvents():ListenForEvent( event, listener, fn, priority )
end

function Entity:RemoveListener( listener )
	local events = self:GetEvents()
	events:RemoveListener( listener )
	if not events:HasListeners() then
		self.events = nil
	end
end

function Entity:BroadcastEvent( event_name, ... )
	if self.events then
		self.events:BroadcastEvent( event_name, self, ... )
	end
end

function Entity:GetEvents()
	if self.events == nil then
		self.events = EventSystem()
	end
	return self.events
end

function Entity:IsSpawned()
	return self.world ~= nil
end

function Entity:Despawn()
	self.world:DespawnEntity( self )
end

function Entity:OnSpawn( world )
	assert( self.world == nil or error( tostr(self) ))

	self.world = world

	if self.guid == nil then
		self.guid = world:GenerateID()
	end

	if self.aspects then
		for i, aspect in ipairs( self.aspects ) do
			if aspect.OnSpawn then
				aspect:OnSpawn( world )
			end
		end
	end

	if self.OnTickUpdate then
		assert( self.tick_duration )
		assert( self.tick_update_ev == nil )
		self.tick_update_ev = world:SchedulePeriodicFunction( self.tick_duration, self.tick_duration, self.OnTickUpdate, self )
	end
end

function Entity:OnDespawn()
	assert( self.world )

	if self.tick_update_ev then
		self.world:UnscheduleEvent( self.tick_update_ev )
	end

	if self.aspects then
		for i, aspect in ipairs( self.aspects ) do
			if aspect.OnDespawn then
				aspect:OnDespawn()
			end
		end
	end

	self.world = nil
end

function Entity:AddTag( tag )
	if self.tags == nil then
		self.tags = {}
	end
	table.insert( self.tags, tag )
end

function Entity:HasTag( tag )
	return self.tags and table.contains( self.tags, tag )
end

function Entity:GainAspect( aspect )
	assert( is_instance( aspect, Aspect ), "Not an aspect: "..tostring(aspect) )
	
	if self.aspects == nil then
		self.aspects = {}
		self.aspects_by_id = {}
	end

	assert( not table.contains( self.aspects, aspect ))
	table.insert( self.aspects, aspect )

	local id = aspect:GetID()
	assert( self.aspects_by_id[ id ] == nil or error( "Aspect id exists:" .. tostring(id)))
	self.aspects_by_id[ id ] = aspect

	aspect:OnGainAspect( self )

	if self.world and aspect.OnSpawn then
		aspect:OnSpawn( self.world )
	end

	self:BroadcastEvent( ENTITY_EVENT.ASPECT_GAINED, aspect )

	return aspect
end

function Entity:LoseAspect( arg )
	local aspect = self:GetAspect( arg )
	local id = aspect:GetID()
	assert( self.aspects_by_id[ id ] == aspect or error( string.format( "aspect %s found instead with id %s", tostring(self.aspects_by_id[ id ] ), tostring( id ))))
	table.arrayremove( self.aspects, aspect )
	self.aspects_by_id[ id ] = nil

	if self.world and aspect.OnDespawn then
		aspect:OnDespawn()
	end
	aspect:OnLoseAspect( self )

	if #self.aspects == 0 then
		self.aspects = nil
		self.aspects_by_id = nil
	end

	self:BroadcastEvent( ENTITY_EVENT.ASPECT_LOST, aspect )
end

function Entity:GetAspect( arg )
	assert( arg ~= nil, "looking for nil Aspect" )
	if type(arg) == "string" then
		return self.aspects_by_id[ arg ]

	elseif is_class( arg ) and self.aspects then
		for id, aspect in ipairs( self.aspects ) do
			if is_instance( aspect, arg ) then
				return aspect
			end
		end

	elseif self.aspects and table.contains( self.aspects, arg ) then
		return arg
	end
end

function Entity:HasAspect( arg )
	return self:GetAspect( arg ) ~= nil
end

function Entity:Aspects()
	return ipairs( self.aspects or table.empty )
end


function Entity:__tostring()
	if self.guid then
		return string.format( "%d-%s", self.guid, self._classname )
	else
		return self._classname
	end
end


