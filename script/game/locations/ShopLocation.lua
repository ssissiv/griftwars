local ShopLocation = class( "Location.Shop", Location )

ShopLocation.WORLDGEN_TAGS = { "shop exit" }

function ShopLocation:init()
	Location.init( self )

	local shop = self:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))
end

function ShopLocation:OnSpawn( world )
	Location.OnSpawn( self, world )

	Object.Door( "shop exit" ):WarpToLocation( self )
	local shopkeep = self:GetAspect( Feature.Shop ):SpawnShopOwner()
	-- local home = self:SpawnHome( shopkeep )
end

function ShopLocation:GenerateTileMap()
	if self.map == nil then
		local w, h = 7, 8
		self.map = self:GainAspect( Aspect.TileMap( w, h ))
		self.map:FillTiles( function( x, y )
			if x == 1 or y == 1 or x == w or y == h then
				return Tile.StoneWall( x, y )
			else
				return Tile.StoneFloor( x, y )
			end
		end )

		self:SetWaypoint( WAYPOINT.KEEPER, Waypoint( self, 4, 2 ))
	end
end