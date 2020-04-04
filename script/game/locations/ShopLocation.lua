local ShopLocation = class( "Location.Shop", Location )

function ShopLocation:init()
	Location.init( self )
	self:SetImage( assets.LOCATION_BGS.SHOP )
	local shop = self:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))
end

