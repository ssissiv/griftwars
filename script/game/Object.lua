local Object = class( "Object", Entity )

function Object:init()
	Entity.init( self )
	self.value = 0
end

function Object:GetName()
	return "object"
end

function Object:AssignOwner( owner )
	assert( self.owner == nil or owner == nil )
	assert( is_instance( owner, Inventory )) -- likely to be relaxed
	self.owner = owner
end

function Object:Clone()
	local clone = setmetatable( table.shallowcopy( self ), self._class )
	clone.owner = nil -- Not transferrable.
	return clone
end

function Object:Equip()
	self.equipped = true
end

function Object:Unequip()
	self.equipped = false
end

function Object:IsEquipped()
	return self.equipped
end

function Object:GetValue()
	return self.value
end

function Object:DeltaValue( delta )
	self.value = math.max( self.value + delta, 0 )
end

function Object:GetLocation()
	return self.location
end

function Object:__tostring()
	return string.format( "[%s]", self:GetName() )
end