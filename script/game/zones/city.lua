local City = class( "Zone.City", Zone )

City.LOCATIONS = {
	[ Location.CityDistrict1 ] = 1,
	[ Location.CityDistrict2 ] = 1,
	[ Location.EmptyDistrict ] = 2,
	[ Location.Tavern ] = 1,
	[ Location.Residence ] = 1,
	[ Location.Shop ] = 1,
}

City.ZONE_ADJACENCY =
{
	["Zone.Forest"] = 1
}

City.ZONE_COLOUR = { 70, 70, 80 }

function City:OnWorldGenPass( pass )
	if self.name == nil then
		self.name = self.world:GetAspect( Aspect.CityNamePool ):PickName()
	end
	if self.faction == nil then
		self.faction = self.world:CreateFaction( self.name )
	end
	if pass == 0 then
		for i = 1, 3 do
			local room = self:RandomRoom()
			Agent.Scavenger():WarpToLocation( room )
		end
		for i = 1, 3 do
			local room = self:RandomRoom()
			Agent.Snoop():WarpToLocation( room )
		end
		return true

	elseif pass == 1 then
		self:SpawnShopAssistants()
		return true
	end
end

function City:SpawnShopAssistants()
	for i, room in ipairs( self.rooms ) do
		local shop = room:GetAspect( Feature.Shop )
		local keeper = shop and shop:GetShopOwner()
		if keeper then
			local assistant = keeper:GetAspect( Job.ManageShop ):TrySpawnAssistant()
			if assistant then
				assistant:WarpToLocation( self:RandomRoom() )
			end
		end
	end
end

