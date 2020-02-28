local Object = class( "Object", Entity )
Object.MAP_CHAR = "."

function Object:init()
	Entity.init( self )
	self.value = 0
end

function Object:GetName()
	return "object"
end

function Object:GetMapChar()
	return self.MAP_CHAR
end

function Object:GenerateLocTable( viewer )
	local t = { viewer = viewer, name = self:GetName() }

	t.id = loc.format( "<{1}>", self:GetName() )
	t.Id = t.id
	t.name = self:GetName()

	return t
end

function Object:LocTable( viewer )
	if viewer == nil and self.world then
		viewer = self.world:GetPuppet()
	end

	if self.loc_table == nil or self.loc_table.viewer ~= viewer  then
		self.loc_table = self:GenerateLocTable( viewer )
	end
	return self.loc_table
end

function Object:GetShortDesc()
	return loc.format( "{1} is here.", tostring(self))
end

local function WarpToLocation( self, location )
	local prev_location = self.location
	if self.location then
		self.location:RemoveEntity( self )
	end

	if location then
		self.location = location
		location:AddEntity( self )
	end
end

function Object:WarpToNowhere()
	WarpToLocation( self )
end

function Object:WarpToLocation( location )
	assert( is_instance( location, Location ))
	WarpToLocation( self, location )
end

function Object:WarpToAgent( agent )
	self:WarpToLocation( agent:GetLocation() )
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

function Object:SetCoordinate( x, y )
	self.x, self.y = x, y
end

function Object:GetCoordinate()
	return self.x, self.y
end

function Object:GetLocation()
	if self.location then
		return self.location
	elseif self.owner then
		return self.owner:GetLocation()
	end
end

function Object:__tostring()
	return string.format( "[%s]", self:GetName() )
end