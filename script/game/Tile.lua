local Tile = class( "Tile", Entity )

function Tile:init( x, y )
	Entity.init( self )
	self.x, self.y = x, y
end

function Tile:GetShortDesc()
	return self.name or self._classname
end

function Tile:GetCoordinate()
	return self.x, self.y
end

function Tile:SetCoordinate( x, y )
	self.x, self.y = x, y
end

function Tile:AssignRegionID( region_id )
	self.region_id = region_id
	return self
end

function Tile:GetRegionID()
	return self.region_id
end

function Tile:GetDistance( tile )
	return distance( self.x, self.y, tile.x, tile.y )
end

function Tile:IsEmpty()
	return self.contents == nil
end


-- Conditionally passable is passability for path finding purposes.
-- ie. the actor has means to make this Tile passable, even if it isn't
-- strictly passable now.
function Tile:IsConditionallyPassable( what )
	local impass = self:GetAspect( Aspect.Impass )
	if impass and ( what == nil or not impass:IsConditionallyPassable( what ) ) then
		return false, "The tile is impassable"
	end
	if self.contents then
		for i, obj in ipairs( self.contents ) do
			local impass = obj:GetAspect( Aspect.Impass )
			if impass and not impass:IsConditionallyPassable( what ) then
				return false, tostring(obj).." is impassable"
			end
		end
	end

	return true
end

function Tile:IsPassable( what, impassables )
	local impass = self:GetAspect( Aspect.Impass )
	if impass and ( what == nil or not impass:IsPassable( what ) ) then
		if impassables then
			table.insert( impassables, self )
		else
			return false, "The tile is impassable"
		end
	end
	if self.contents then
		for i, obj in ipairs( self.contents ) do
			if obj ~= what then
				local impass = obj:GetAspect( Aspect.Impass )
				if impass and not impass:IsPassable( what ) then
					if impassables then
						table.insert( impassables, obj )
					else
						return false, tostring(obj).." is impassable"
					end
				end
			end
		end
	end

	if impassables then
		return #impassables == 0
	else
		return true
	end
end

function Tile:AddEntity( obj )
	if self.contents == nil then
		self.contents = {}
	end
	assert( not table.contains( self.contents, obj ), tostring(obj))
	table.insert( self.contents, obj )
end

function Tile:RemoveEntity( obj )
	table.arrayremove( self.contents, obj )
	if #self.contents == 0 then
		self.contents = nil
	end
end

function Tile:HasEntity( obj )
	return self.contents and table.contains( self.contents, obj )
end

function Tile:GetContents()
	return self.contents or table.empty
end

function Tile:Contents()
	return ipairs( self.contents or table.empty )
end

function Tile:RenderMapTile( screen, x1, y1, x2, y2 )
	local w, h = x2 - x1, y2 - y1

	if self.image then
		love.graphics.setColor( 255, 255, 255, 255 )
		screen:Image( self.image, x1, y1, w, h )
	else
		love.graphics.setColor( 255, 0, 255, 255 )
		screen:Rectangle( x1, y1, w - 1, h - 1 )
		love.graphics.setColor( 255, 255, 255, 255 )
	end

	for i, aspect in self:Aspects() do
		if aspect.RenderMapTile then
			aspect:RenderMapTile( screen, self, x1, y1, x2, y2 )
		end
	end
end


function Tile:RenderDebugPanel( ui, panel )
	if self.contents and next(self.contents) then
		ui.Text( "Contents:" )
		for i, obj in ipairs( self.contents ) do
			panel:AppendTable( ui, obj )
		end
	end
end

function Tile:__tostring()
	if self.region_id then
		return string.format( "[%s:r%d:%d,%d]", self._classname, self.region_id, tostring(self.x), tostring(self.y))
	else
		return string.format( "[%s:%d,%d]", self._classname, tostring(self.x), tostring(self.y))
	end
end

-----------------------------------------------------------------

local Void = class( "Tile.Void", Tile )

local Grass = class( "Tile.Grass", Tile )
Grass.image = assets.TILE_IMG.GRASS
Grass.name = "Grass"

local Tree = class( "Tile.Tree", Tile )
Tree.image = assets.TILE_IMG.TREE
Tree.name = "Tree"

local DirtFloor = class( "Tile.DirtFloor", Tile )
DirtFloor.image = assets.TILE_IMG.DIRT_FLOOR
DirtFloor.name = "Dirt Floor"


local StoneFloor = class( "Tile.StoneFloor", Tile )
StoneFloor.image = assets.TILE_IMG.STONE_FLOOR
StoneFloor.name = "Stone Floor"

local WoodenFloor = class( "Tile.WoodenFloor", Tile )
WoodenFloor.image = assets.TILE_IMG.WOODEN_FLOOR
WoodenFloor.name = "Wooden Floor"

local StoneWall = class( "Tile.StoneWall", Tile )
StoneWall.image = assets.TILE_IMG.STONE_WALL
StoneWall.name = "Stone Wall"

function StoneWall:init( x, y )
	StoneWall._base.init( self, x, y )
	self:GainAspect( Aspect.Impass( IMPASS.ALL ) )
end

