local District = class( "Location.CityDistrict", Location )

function District:OnSpawn( world )
	Location.OnSpawn( self, world )

	self:SetDetails( loc.format( "District {1}", world:Random(1,9999)),
		"These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")

	self:SpawnPerimeterPortals( "district" )

	local w, h = self.map:GetExtents()
	local boundary = false

	local portal = self:GetBoundaryPortal( EXIT.WEST )
	if portal then
		local x, y = portal.owner:GetCoordinate()
		boundary = true
		self.map:CreateCursor()
			:SetTile( Tile.StoneWall ):SetCoord( x, 0 )
			:LineTo( x, y - 1 ):SetCoord( x, y ):LineTo( x, h )
	end

	local portal = self:GetBoundaryPortal( EXIT.EAST )
	if portal then
		local x, y = portal.owner:GetCoordinate()
		boundary = true
		self.map:CreateCursor()
			:SetTile( Tile.StoneWall ):SetCoord( x, 0 )
			:LineTo( x, y - 1 ):SetCoord( x, y ):LineTo( x, h )
	end

	local portal = self:GetBoundaryPortal( EXIT.SOUTH )
	if portal then
		local x, y = portal.owner:GetCoordinate()
		boundary = true
		self.map:CreateCursor()
			:SetTile( Tile.StoneWall ):SetCoord( 0, y )
			:LineTo( x - 1, y ):SetCoord( x, y ):LineTo( w, y )
	end

	local portal = self:GetBoundaryPortal( EXIT.NORTH )
	if portal then
		local x, y = portal.owner:GetCoordinate()
		boundary = true
		self.map:CreateCursor( 1, 1 )
			:SetTile( Tile.StoneWall ):SetCoord( 0, y )
			:LineTo( x - 1, y ):SetCoord( x, y ):LineTo( w, y )
	end
end

function District:SpawnDoor( tags )
	local door = Object.Door( tags )
	local w, h = self.map:GetExtents()
	local tile = self:FindPassableTile( self.world:Random( 2, w - 1 ), self.world:Random( 2, h - 1 ), door )
	door:WarpToLocation( self, tile:GetCoordinate() )
end


function District:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( self.world:Random( 10, 12 ), self.world:Random( 6, 12 ) ))
		self.map:FillTiles( function( x, y )
			return Tile.StoneFloor( x, y )
		end )
	end
end

---------------------------------------------------

local District1 = class( "Location.CityDistrict1", District )

District1.WORLDGEN_TAGS = {
 "boundary east", "boundary west", "boundary south", "boundary north",
 "district west", "district east", "district north", "district south", "shop entry", "tavern entry"
}

function District1:OnSpawn( world )
	District.OnSpawn( self, world )

	self:SpawnDoor( "shop entry" )
	self:SpawnDoor( "shop entry" )
	self:SpawnDoor( "tavern entry" )
end

---------------------------------------------------

local District2 = class( "Location.CityDistrict2", District )

District2.WORLDGEN_TAGS = {
 "boundary east", "boundary west", "boundary south", "boundary north",
 "district west", "district east", "district north", "district south", "residence entry" }

function District2:OnSpawn( world )
	District.OnSpawn( self, world )

	self:SpawnDoor( "residence entry" )
	self:SpawnDoor( "residence entry" )

	for i = 1, world:Random( 6 ) do
		Object.JunkHeap():WarpToLocation( self )
	end
end


---------------------------------------------------

local EmptyDistrict = class( "Location.EmptyDistrict", District )

EmptyDistrict.WORLDGEN_TAGS = {
 "boundary east", "boundary west", "boundary south", "boundary north",
 "district west", "district east", "district north", "district south" }

