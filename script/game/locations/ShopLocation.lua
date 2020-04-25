local ShopLocation = class( "Location.Shop", Location )

ShopLocation.WORLDGEN_TAGS = { "shop exit" }

function ShopLocation:init()
	Location.init( self )
	self:SetImage( assets.LOCATION_BGS.SHOP )
	self:GainAspect( Aspect.BuildingTileMap( 8, 8 ))
	local shop = self:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))

	Object.Door( "shop exit" ):WarpToLocation( self )
end

function ShopLocation:OnSpawn( world )
	Location.OnSpawn( self, world )

	local shopkeep = self:GetAspect( Feature.Shop ):SpawnShopOwner()
	-- local home = self:SpawnHome( shopkeep )
end
