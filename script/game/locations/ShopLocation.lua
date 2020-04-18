local ShopLocation = class( "Location.Shop", Location )

function ShopLocation:init()
	Location.init( self )
	self:SetImage( assets.LOCATION_BGS.SHOP )
	self:GainAspect( Aspect.BuildingTileMap( 8, 8 ))
	local shop = self:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))
end

