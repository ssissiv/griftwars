local District = class( "Location.CityDistrict", Location )

function District:init( zone )
	Location.init( self )
	self:SetDetails( loc.format( "District of {1}{2}", zone.name, math.random(1,9999)), "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
end

function District:OnSpawn( world )
	Location.OnSpawn( self, world )

	local w, h = self.map:GetExtents()
	local exit = Object.Portal( "district west" ):WarpToLocation( self, 1, math.floor(h/2) )
	local exit = Object.Portal( "district east" ):WarpToLocation( self, w, math.floor(h/2) )
end

function District:SpawnDoor( tags )
	local door = Object.Door( tags )
	local w, h = self.map:GetExtents()
	local tile = self:FindPassableTile( math.random( 2, w - 1 ), math.random( 2, h - 1 ), door )
	door:WarpToLocation( self, tile:GetCoordinate() )
end

function District:GenerateTileMap()
	if self.map == nil then
		self.map = self:GainAspect( Aspect.TileMap( math.random( 6, 12 ), math.random( 6, 12 ) ))
		self.map:FillTiles( function( x, y )
			return Tile.StoneFloor( x, y )
		end )
	end
end

---------------------------------------------------

local District1 = class( "Location.CityDistrict1", District )

District1.WORLDGEN_TAGS = { "district west", "district east", "shop entry", "tavern entry" }

function District1:OnSpawn( world )
	District.OnSpawn( self, world )

	self:SpawnDoor( "shop entry" )
	self:SpawnDoor( "shop entry" )
	self:SpawnDoor( "tavern entry" )
end

---------------------------------------------------

local District2 = class( "Location.CityDistrict2", District )

District2.WORLDGEN_TAGS = { "district west", "district east", "residence entry" }

function District2:OnSpawn( world )
	District.OnSpawn( self, world )

	self:SpawnDoor( "residence entry" )
	self:SpawnDoor( "residence entry" )
end
