local Entity = class( "Entity" )

function Entity:init()
end

function Entity:ListenForAny( listener, fn, priority )
	self:GetEvents():ListenForAny( listener, fn, priority )
end

function Entity:ListenForEvent( event, listener, fn, priority )
	self:GetEvents():ListenForEvent( event, listener, fn, priority )
end

function Entity:ListenForEvent( event, listener, fn, priority )
	self:GetEvents():ListenForEvent( event, listener, fn, priority )
end

function Entity:RemoveListener( listener )
	self:GetEvents():RemoveListener( listener )
end

function Entity:BroadcastEvent( event_name, ... )
	self:GetEvents():BroadcastEvent( event_name, self, ... )
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

function Entity:OnSpawn( world )
	assert( self.world == nil )
	self.world = world

	if self.aspects then
		for i, aspect in ipairs( self.aspects ) do
			if aspect.OnSpawn then
				aspect:OnSpawn( world )
			end
		end
	end
end

function Entity:OnDespawn()
	assert( self.world )

	if self.aspects then
		for i, aspect in ipairs( self.aspects ) do
			if aspect.OnDespawn then
				aspect:OnDespawn()
			end
		end
	end

	self.world = nil
end

function Entity:GainAspect( aspect )
	if self.aspects == nil then
		self.aspects = {}
		self.aspects_by_id = {}
	end

	local id = aspect:GetID()
	table.insert( self.aspects, aspect )
	assert( self.aspects_by_id[ id ] == nil )
	self.aspects_by_id[ id ] = aspect
	aspect:OnGainAspect( self )

	if self.world and aspect.OnSpawn then
		aspect:OnSpawn( self.world )
	end

	return aspect
end

function Entity:LoseAspect( aspect )
	local id = aspect:GetID()
	assert( self.aspects_by_id[ id ] == aspect )
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
end

function Entity:GetAspect( arg )
	assert( arg ~= nil )
	local id
	if type(arg) == "string" then

	elseif type(arg) == "string" then
		id = arg

	elseif is_class( arg ) and self.aspects then
		for id, aspect in ipairs( self.aspects ) do
			if is_instance( aspect, arg ) then
				return aspect
			end
		end

	elseif self.aspects_by_id then
		return self.aspects_by_id[ id ]
	end
end

function Entity:HasAspect( arg )
	return self:GetAspect( arg ) ~= nil
end

function Entity:Aspects()
	return ipairs( self.aspects or table.empty )
end


function Entity:__tostring()
	return self._classname
end


