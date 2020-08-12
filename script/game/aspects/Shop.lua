--------------------------------------------------------------
-- Marks a location used as a Shop front.
--
-- Locations have: Feature.Shop (shop_owner: Agent)
-- Agents have: Job.ManageShop (shop: Location)

local Shop = class( "Feature.Shop", Feature )

function Shop:init( shop_type )
	assert( IsEnum( shop_type, SHOP_TYPE ))
	self.shop_type = shop_type
end

function Shop:GetShopType()
	return self.shop_type
end

function Shop:AssignShopOwner( agent )
	assert( is_instance( agent, Agent ))
	if agent ~= self.shop_owner then
		assert( agent == nil or self.shop_owner == nil )
		self.shop_owner = agent
		local shopkeep = agent:GetAspect( Job.ManageShop )
		shopkeep:AssignShop( self.location )
	end
end

function Shop:GetShopOwner()
	return self.shop_owner
end

function Shop:SpawnShopOwner()
	local world = self:GetWorld()	
	local stock = {}
	local shop_type = self.shop_type
	if shop_type == SHOP_TYPE.FOOD then
		table.insert( stock, Object.Jerky() )

	elseif shop_type == SHOP_TYPE.EQUIPMENT then
		table.insert( stock, Weapon.Dirk() )

	else
		table.insert( stock, Object.ShoddyRope() )
		table.insert( stock, Object.TradeGoods() )
	end

	local shopkeep = Agent.Shopkeeper()
	world:SpawnAgent( shopkeep, self.location )
	
	local shop = shopkeep:GetAspect( Job.ManageShop )
	for i, obj in ipairs( stock ) do
		shop:AddShopItem( obj )
	end

	self:AssignShopOwner( shopkeep )
	return shopkeep
end


