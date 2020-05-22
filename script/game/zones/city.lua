local City = class( "Zone.City", Zone )

City.LOCATIONS = {
	Location.CityDistrict1, 1,
	Location.CityDistrict2, 1,
	Location.EmptyDistrict, 2,
	Location.Tavern, 1,
	Location.Residence, 1,
	Location.Shop, 1,
	Location.MilitaryHQ, 1,
}

City.ZONE_ADJACENCY =
{
	"Zone.Forest", 1,
	"Zone.Hills", 1,
}

City.ZONE_COLOUR = { 70, 70, 80 }

function City:OnWorldGenPass( pass )
	if self.name == nil then
		self.name = self.world:GetAspect( Aspect.CityNamePool ):PickName()
	end
	if self.faction == nil then
		local guards = table.count_if( self.rooms, function( room ) return room:GetBoundaryPortal() end )
		self.faction = Faction.CityMilitary( loc.format( "The {1} Military", self.name ), guards * 3 )
		self.world:SpawnEntity( self.faction )
	end

	if pass == 0 then
		-- Spawn city walls at boundary locations
		for i, room in ipairs( self.rooms ) do
			if room.SpawnCityWalls then
				room:SpawnCityWalls()
			end
		end
		return true

	elseif pass == 1 then
		for i = 1, 3 do
			local room = self:RandomRoomOfClass( Location.CityDistrict )
			Agent.Scavenger():WarpToLocation( room )
		end
		for i = 1, 3 do
			local room = self:RandomRoomOfClass( Location.CityDistrict )
			Agent.Snoop():WarpToLocation( room )
		end

		-- Localize faction members.
		for i, room in ipairs( self.rooms ) do
			if is_instance( room, Location.MilitaryHQ ) then
				self.faction:GetAgentsByRole( FACTION_ROLE.CAPTAIN )[1]:WarpToLocation( room )

			elseif room:GetBoundaryPortal() then
				for i = 1, 3 do
					for j, guard in ipairs( self.faction:GetAgentsByRole( FACTION_ROLE.GUARD )) do
						if not guard:GetLocation() then
							guard:WarpToLocation( room )
							break
						end
					end
				end
			end
		end

		self.faction:VerifyAgentLocations()

		return true

	elseif pass == 1 then
		self:SpawnShopAssistants()
		return true
	end
end

function City:GetFaction()
	return self.faction
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

