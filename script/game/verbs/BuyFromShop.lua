
local BuyFromShop = class( "Verb.BuyFromShop", Verb )

function BuyFromShop:init( actor, shopkeeper, shop )
	Verb.init( self, actor )
	assert( is_instance( shopkeeper, Agent ))
	assert( is_instance( shop, Feature.Shop ))
	self.shopkeeper = shopkeeper
	self.shop = shop
end

function BuyFromShop:GetActDesc( viewer )
	return loc.format( "Buy goods from {1}", self.shopkeeper )
end

function BuyFromShop:CanInteract()
	local job = self.shopkeeper:GetAspect( Job.ManageShop )
	if not job:IsDoing() then
		local ok, reason = job:ShouldDo()
		if not ok then
			return false, reason
		else
			return false, "Not on the job"
		end
	end

	return Verb.CanInteract( self )
end

function BuyFromShop:Interact()
	while not self:IsCancelled() do
		local item = self.world.nexus:ChooseBuyItem( self.shopkeeper, self.actor, self.shop )
		if item then
			self.shopkeeper:GetAspect( Job.ManageShop ):SellToBuyer( item, self.actor )
		else
			break
		end
	end
end