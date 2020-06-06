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

function Tile:Neighbours( map )
	return map:Neighbours( self )
end

function Tile:IsPassable( obj )
	local impass = self:GetAspect( Aspect.Impass )
	if impass and ( obj == nil or not impass:IsPassable( obj ) ) then
		return false
	end
	if self.contents then
		for i, obj in ipairs( self.contents ) do
			local impass = obj:GetAspect( Aspect.Impass )
			if impass and not impass:IsPassable( obj ) then
				return false
			end
		end
	end
	return true
end

function Tile:AddEntity( obj )
	if self.contents == nil then
		self.contents = {}
	end

	print( obj, debug.traceback() )
	table.insert( self.contents, obj )
end

function Tile:RemoveEntity( obj )
	table.arrayremove( self.contents, obj )
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
			ui.SameLine( 0, 10 )
			panel:AppendTable( ui, obj )
		end
	end
end

function Tile:__tostring()
	return string.format( "[%s:%d,%d]", self._classname, tostring(self.x), tostring(self.y))
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
	self:GainAspect( Aspect.Impass() ):SetWall( true )
end

