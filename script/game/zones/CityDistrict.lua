local District = class( "Location.CityDistrict", Location )

function District:init( zone )
	Location.init( self )
	self:GainAspect( Aspect.CityDistrictTileMap( math.random( 6, 12 ), math.random( 6, 12 ) ))
	self:SetDetails( loc.format( "District of {1}{2}", zone.name, math.random(1,9999)), "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	self:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
end

function District:OnSpawn( world )
	Location.OnSpawn( self, world )

	self:GainAspect( Aspect.TileMap( 8, 8 ))
	local map = self:GenerateTileMap()

	local w, h = map:GetExtents()

	local exit = Object.Portal( "district" ):WarpToLocation( self, 1, math.floor(h/2) )
	local exit = Object.Portal( "district" ):WarpToLocation( self, w, math.floor(h/2) )
end

local CityDistrictTileMap = class( "Aspect.CityDistrictTileMap", Aspect.TileMap )

function CityDistrictTileMap:GenerateTileMap()
	self:FillTiles( function( x, y )
		return Tile.StoneFloor( x, y )
	end )
end

---------------------------------------------------

local District1 = class( "Location.CityDistrict1", District )

District1.WORLDGEN_TAGS = { "district", "city_shop" }

function District1:OnSpawn( world )
	District.OnSpawn( self, world )

	Object.Door( "city_shop" ):WarpToLocation( self )
	Object.Door( "city_shop" ):WarpToLocation( self )
end

---------------------------------------------------

local District2 = class( "Location.CityDistrict2", District )

District2.WORLDGEN_TAGS = { "district", "city_residence" }

function District1:OnSpawn( world )
	District.OnSpawn( self, world )

	Object.Door( "city_residence" ):WarpToLocation( self )
	Object.Door( "city_residence" ):WarpToLocation( self )
end
