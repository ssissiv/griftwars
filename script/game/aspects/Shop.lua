--------------------------------------------------------------
-- Marks a location used as a Shop front.
--
-- Locations have: Feature.Shop (shop_owner: Agent)
-- Agents have: Job.Shopkeep (shop: Location)

local Shop = class( "Feature.Shop", Feature )

function Shop:init( shop_type )
	assert( IsEnum( shop_type, SHOP_TYPE ))
	self.shop_type = shop_type
end

function Shop:AssignShopOwner( agent )
	assert( is_instance( agent, Agent ))
	if agent ~= self.shop_owner then
		assert( agent == nil or self.shop_owner == nil )
		self.shop_owner = agent
		local shopkeep = agent:GetAspect( Job.Shopkeep )
		shopkeep:AssignShop( self.location )
	end
end

function Shop:SpawnShopOwner()
	local world = self:GetWorld()	
	local stock = {}
	local shop_type = self.shop_type
	if shop_type == SHOP_TYPE.FOOD then
		table.insert( stock, Object.Jerky() )

	elseif shop_type == SHOP_TYPE.EQUIPMENT then
		table.insert( stock, Weapon.Dirk() )
	end

	if self.name == nil then
		local adj = world.adjectives:PickName()
		local noun = world.nouns:PickName()
		local name
		if shop_type == SHOP_TYPE.FOOD then
			name = loc.format( "The {1} {2} Restaurant", adj, noun )
		elseif shop_type == SHOP_TYPE.EQUIPMENT then
			name = loc.format( "{1} {2}'s' Equipment", adj, noun )
		else
			name = loc.format( "The {1} {2} General Store", adj, noun )
		end

		self.location:SetDetails( name )
	end

	local shopkeep = Agent.Shopkeeper()
	world:SpawnAgent( shopkeep, self.location )
	
	local shop = shopkeep:GetAspect( Job.Shopkeep )
	for i, obj in ipairs( stock ) do
		shop:AddShopItem( obj )
	end

	self:AssignShopOwner( shopkeep )
	return shopkeep
end


