local Entity = class( "Entity" )

function Entity:init()
end

function Entity:OnSpawn( world )
	assert( self.world == nil )
	self.world = world
end

function Entity:OnDespawn()
	assert( self.world )
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
	if is_instance( aspect, Aspect.StatValue ) then
		self.stats[ id ] = aspect
	end
	aspect:OnGainAspect( self )

	return aspect
end

function Entity:LoseAspect( aspect )
	local id = aspect:GetID()
	assert( self.aspects_by_id[ id ] == aspect )
	table.arrayremove( self.aspects, aspect )
	self.aspects_by_id[ id ] = nil
	if is_instance( aspect, Aspect.StatValue ) then
		self.stats[ id ] = nil
	end
	aspect:OnLoseAspect( self )

	if #self.aspects == 0 then
		self.aspects = nil
		self.aspects_by_id = nil
	end
end

function Entity:GetAspect( arg )
	local id
	if type(arg) == "string" then
		id = arg
	elseif is_class( arg ) then
		id = arg._classname
	end

	if self.aspects_by_id then
		return self.aspects_by_id[ id ]
	end
end

function Entity:HasAspect( arg )
	local id
	if type(arg) == "string" then
		id = arg
	elseif is_class( arg ) then
		id = arg._classname
	end

	if self.aspects_by_id then
		return self.aspects_by_id[ id ] ~= nil
	end
end

function Entity:Aspects()
	return ipairs( self.aspects or table.empty )
end


function Entity:__tostring()
	return self._classname
end


