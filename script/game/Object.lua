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

function Object:GetShortDesc( viewer )
	return loc.format( "{1} is here.", tostring(self))
end

local function WarpToLocation( self, location, x, y )
	local prev_location = self.location
	if self.location then
		self.location:RemoveEntity( self )
	end

	if location then
		self.location = location
		self:SetCoordinate( x, y )
		location:AddEntity( self )
	end

	if self.OnLocationChanged then
		self:OnLocationChanged( prev_location, location )
	end
	for i, aspect in self:Aspects() do
		if aspect.OnLocationChanged then
			aspect:OnLocationChanged( prev_location, location )
		end
	end
end

function Object:WarpToNowhere()
	WarpToLocation( self )
end

function Object:WarpToLocation( location, x, y )
	assert( is_instance( location, Location ))
	WarpToLocation( self, location, x, y )
end

function Object:WarpToAgent( agent )
	self:WarpToLocation( agent:GetLocation() )
end

function Object:AssignCarrier( carrier )
	assert( is_instance( carrier, Aspect.Inventory )) -- likely to be relaxed
	self.carrier = carrier
end

function Object:GetCarrier()
	return self.carrier
end

function Object:Clone()
	local clone = setmetatable( table.shallowcopy( self ), self._class )
	clone.carrier = nil -- Not transferrable.
	return clone
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

function Object:GetTile()
	if self.location then
		return self.location:GetTileAt( self.x, self.y )
	end
end

function Object:GetLocation()
	if self.location then
		return self.location
	elseif self.carrier then
		return self.carrier:GetLocation()
	end
end

function Object:RenderMapTile( screen, tile, x1, y1, x2, y2 )
	if self.image then
		local sx, sy = (x2 - x1) / self.image:getWidth(), (y2 - y1) / self.image:getHeight()
		love.graphics.setColor( 255, 255, 255, 255 )
		screen:Image( self.image, x1, y1, sx, sy )

	else
		love.graphics.setFont( assets.FONTS.MAP_TILE )
		local ch, clr = self:GetMapChar()
		love.graphics.setColor( table.unpack( clr or constants.colours.WHITE ))
		local scale = DEFAULT_ZOOM / screen.camera:GetZoom()
		love.graphics.print( ch or "?", x1 + (x2-x1)/6, y1, 0, 1.4 * scale, 1 * scale )
	end
end

function Object:__tostring()
	return string.format( "<%s>", self:GetName() )
end