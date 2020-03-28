local Tile = class( "Tile", Entity )

function Tile:init( x, y )
	Entity.init( self )
	self.x, self.y = x, y
end

function Tile:GetCoordinate()
	return self.x, self.y
end

function Tile:SetCoordinate( x, y )
	self.x, self.y = x, y
end

function Tile:IsPassable( obj )
	local impass = self:GetAspect( Aspect.Impass )
	if impass and not impass:IsPassable( obj ) then
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

	table.insert( self.contents, obj )
end

function Tile:RemoveEntity( obj )
	table.arrayremove( self.contents, obj )
end

function Tile:HasEntity( obj )
	return self.contents and table.contains( self.contents, obj )
end

function Tile:Contents()
	return ipairs( self.contents or table.empty )
end

function Tile:RenderMapTile( screen, x1, y1, x2, y2 )
	local w, h = x2 - x1, y2 - y1

	if self.image then
		local sx, sy = w / self.image:getWidth(), h / self.image:getHeight()
		love.graphics.setColor( 255, 255, 255, 255 )
		screen:Image( self.image, x1, y1, sx, sy )
	else
		love.graphics.setColor( 255, 0, 255, 255 )
		screen:Rectangle( x1, y1, w - 1, h - 1 )
		love.graphics.setColor( 255, 255, 255, 255 )
	end

	if self.contents then
		for i, obj in ipairs( self.contents ) do
			if obj.RenderMapTile then
				obj:RenderMapTile( screen, self, x1, y1, x2, y2 )
			end

			-- if is_instance( obj, Agent ) then
			-- 	love.graphics.setColor( 255, 0, 255 )
			-- elseif is_instance( obj, Structure ) then
			-- 	love.graphics.setColor( 0, 0, 0 )
			-- else
			-- 	love.graphics.setColor( 255, 255, 0 )
			-- end

			-- screen:Rectangle( x, y, sz, sz )
			-- x = x + sz + margin
			-- if x >= x2 - margin - 4 then
			-- 	x, y = x1 + 4 + margin, y + sz + margin
			-- end
		end
	end
end

function Tile:__tostring()
	return string.format( "[%s:%d,%d]", self._classname, tostring(self.x), tostring(self.y))
end

-----------------------------------------------------------------

local Grass = class( "Tile.Grass", Tile )
Grass.image = assets.TILE_IMG.GRASS

local StoneFloor = class( "Tile.StoneFloor", Tile )
StoneFloor.image = assets.TILE_IMG.STONE_FLOOR

local StoneWall = class( "Tile.StoneWall", Tile )
StoneWall.image = assets.TILE_IMG.STONE_WALL

function StoneWall:init( x, y )
	StoneWall._base.init( self, x, y )
	self:GainAspect( Aspect.Impass() )
end

