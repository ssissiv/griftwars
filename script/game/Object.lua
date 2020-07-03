local Object = class( "Object", Entity )
Object.MAP_CHAR = "."

function Object:init()
	Entity.init( self )
	self.value = 0
end

function Object:OnDespawn()
	Entity.OnDespawn( self )

	assert( not self:IsSpawned() )
	if self.carrier then
		self.carrier:RemoveItem( self )
	end

	if self.location then
		self.location:RemoveEntity( self )
	end
end

function Object:GetName()
	return "object"
end

function Object:GetMapChar()
	return self.MAP_CHAR, self.MAP_COLOUR
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
	return tostring(self)
	-- return loc.format( "{1} is here.", tostring(self))
end

function Object:GetDesc( viewer )
	return self.desc
end

function Object:Inscribe( txt )
	self.scribe_txt = txt
	return self
end

function Object:IsInscribed( txt )
	return self.scribe_txt:find( txt )
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

function Object:WarpToTile( tile )
	local prev_tile = self.x and self.location:GetTileAt( self.x, self.y )
	if prev_tile then
		prev_tile:RemoveEntity( self )
	end

	self:SetCoordinate( tile:GetCoordinate() )

	tile:AddEntity( self )

	self:BroadcastEvent( ENTITY_EVENT.TILE_CHANGED, tile, prev_tile )
end

function Object:WarpToAgent( agent )
	self:WarpToLocation( agent:GetLocation() )
end

function Object:AssignCarrier( carrier )
	assert( carrier == nil or is_instance( carrier, Aspect.Inventory )) -- likely to be relaxed

	if self.carrier_handlers and self.carrier and is_instance( self.carrier.owner, Agent ) then
		self.carrier.owner:RemoveListener( self )
	end

	self.carrier = carrier

	if self.carrier_handlers and carrier and is_instance( carrier.owner, Agent ) then
		for ev, fn in pairs( self.carrier_handlers ) do
			carrier.owner:ListenForEvent( ev, self, fn )
		end
	end
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

function Object:RenderTooltip( ui, screen, viewer )
	local desc = self:GetDesc( viewer )
	ui.BeginTooltip()
	local desc = self:GetDesc( viewer )
	if desc then
		ui.TextColored( 0.8, 0.8, 0.8, 1, tostring(desc) )
		ui.Spacing()
	end
	if self.attack_power then
		ui.Text( "Attack:" )
		ui.SameLine( 0, 5 )
		ui.TextColored( 0.8, 0, 0, 1, tostring(self.attack_power) )
	end

	ui.Text( "Value:" )
	ui.SameLine( 0, 5 )
	ui.TextColored( 1, 1, 0, 1, tostring(self:GetValue() ))
	ui.EndTooltip()
end

function Object:RenderMapTile( screen, tile, x1, y1, x2, y2 )
	if self.image then
		love.graphics.setColor( 255, 255, 255, 255 )
		screen:Image( self.image, x1, y1, x2 - x1, y2 - y1 )

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