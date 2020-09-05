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
		self:GenerateCityFaction()
	end

	if pass == 0 then
		Zone.OnWorldGenPass( self, pass )
	-- 	-- Spawn city walls at boundary locations
	-- 	for i, room in ipairs( self.rooms ) do
	-- 		if room.SpawnCityWalls and room:SpawnCityWalls() > 0 then
	-- 			self.faction:AddPatrolLocation( room, 3 )
	-- 		end
	-- 	end
		return true

	elseif pass == 1 then
		for i = 1, 3 do
			local room = self:RandomRoomOfClass( Location.CityDistrict )
			Agent.Scavenger():WarpToLocation( room )
		end
		for i = 1, 3 do
			local room = self:RandomRoomOfClass( Location.Tavern )
			if room then
				Agent.Snoop():WarpToLocationRegion( room, RGN_SERVING_AREA )
			end
		end

		-- Localize faction members.
		for i, room in ipairs( self.rooms ) do
			if is_instance( room, Location.MilitaryHQ ) then
				local commander = self.faction:GetAgentsByRole( FACTION_ROLE.COMMANDER )[1]
				commander:WarpToLocation( room )
				local tile = commander:GetTile()
				coroutine.yield( YIELD_CMD.LOCATION, room )
				coroutine.yield( YIELD_CMD.PAN_TILE, tile )
				coroutine.yield( YIELD_CMD.CAPTION, commander.faction:GetRoleTitle(), tile.x, tile.y - 1, 1.0 )

			elseif room:GetBoundaryPortal() then
				for i, captain in ipairs( self.faction:GetAgentsByRole( FACTION_ROLE.CAPTAIN )) do
					if not captain:GetLocation() then
						captain:WarpToLocation( room )
						break
					end
				end

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

function City:GenerateCityFaction()
	local guards = table.count_if( self.rooms, function( room ) return room:GetBoundaryPortal() end )
	self.faction = Faction.CityMilitary( loc.format( "The {1} Military", self.name ), guards * 3 )
	self.world:SpawnEntity( self.faction )

	for i, room in ipairs( self.rooms ) do
		room:GainAspect( Aspect.FactionMember( self.faction ))
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

