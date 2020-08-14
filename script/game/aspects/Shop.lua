--------------------------------------------------------------
-- Marks a location used as a Shop front.
--
-- Locations have: Feature.Shop (shop_owner: Agent)
-- Agents have: Job.ManageShop (shop: Location)

local Shop = class( "Feature.Shop", Feature )

function Shop:init( shop_type )
	assert( IsEnum( shop_type, SHOP_TYPE ))
	self.shop_type = shop_type
	self:SpawnStock()
end

function Shop:GetShopType()
	return self.shop_type
end

function Shop:ShopItems()
	return ipairs( self.stock )
end

function Shop:AssignShopOwner( agent )
	assert( is_instance( agent, Agent ))
	if agent ~= self.shop_owner then
		assert( agent == nil or self.shop_owner == nil )
		self.shop_owner = agent
		local shopkeep = agent:GetAspect( Job.ManageShop )
		shopkeep:AssignShop( self )
	end
end

function Shop:GetShopOwner()
	return self.shop_owner
end

function Shop:SpawnStock()
	self.stock = {}
	if self.shop_type == SHOP_TYPE.FOOD then
		table.insert( self.stock, Object.Jerky() )

	elseif self.shop_type == SHOP_TYPE.EQUIPMENT then
		table.insert( self.stock, Weapon.Dirk() )

	else
		table.insert( self.stock, Object.ShoddyRope() )
	end
end

function Shop:AddStock( obj )
	table.insert( self.stock, obj )
end

function Shop:SpawnShopOwner()
	-- Spawn the shop owner.
	local shopkeep = Agent.Shopkeeper()
	self:GetWorld():SpawnAgent( shopkeep, self.location )	
	self:AssignShopOwner( shopkeep )

	return shopkeep
end


