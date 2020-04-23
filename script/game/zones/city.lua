local City = class( "WorldGen.City", Zone )

function City:init( worldgen, origin, sz )
	assert( sz )
	Zone.init( self, worldgen )
	self.roads = {}
	self.home_count = 0
	self.origin = origin
	self.size = sz or 1
end

function City:GenerateZone()
	local world = self.world

	self.name = world:GetAspect( Aspect.CityNamePool ):PickName()
	self.faction = world:CreateFaction( self.name )

	local origin = self.origin or self:SpawnRoad( 0, 0 )
	self.worldgen:SproutLocations( origin, self.size, function() return self:SpawnRoad() end )

	-- Shops
	for i = 1, 1 do
		self:SpawnShop()
	end

	self:SpawnTavern()
	self:SpawnMilitary()

	-- Scavengers
	local poor_house = self.worldgen:Sprout( self.worldgen:RandomAvailableLocation( self.roads, 1 ), function()
			local location = Location()
			location:GainAspect( Feature.Home() )
			location:SetDetails( "Under a Bridge" )
			return location
		end )

	for i = 1, 3 do
		local scavenger = world:SpawnAgent( Agent.Scavenger(), self:RandomRoad() )
		if poor_house then
			poor_house:GetAspect( Feature.Home ):AddResident( scavenger )
		end
	end

	-- Snoops
	for i = 1, 2 do
		local snoop = world:SpawnAgent( Agent.Snoop(), poor_house )
		if poor_house then
			poor_house:GetAspect( Feature.Home ):AddResident( snoop )
		end
	end
end

function City:SpawnRoad( x, y )
	local road = Location.Road( self )
	if x and y then
		road:SetCoordinate( x, y )
		self:SpawnLocation( road )
	end

	table.insert( self.roads, road )
	table.insert( self.rooms, road )

	if self.worldgen:Random() < 0.2 then
		Object.JunkHeap():WarpToLocation( road )
	end

	return road
end

function City:SpawnHome( resident )
	local room = Location.Residence()
	if resident then
		room:SetResident( resident )
	end
	self:SpawnLocation( room )

	local door = Object.Door()
	door:WarpToLocation( self:RandomRoad() )
	door:Connect( room )

	local rdoor = Object.Door()
	rdoor:WarpToLocation( room )
	rdoor:Connect( door.location )

	table.insert( self.rooms, room )
	return room
end

function City:SpawnShop()
	local shop_room = Location.Shop()
	self:SpawnLocation( shop_room )

	local door = Object.Door()
	door:WarpToLocation( self:RandomRoad() )
	door:Connect( shop_room )

	local rdoor = Object.Door()
	rdoor:WarpToLocation( shop_room )
	rdoor:Connect( door.location )

	local shopkeep = shop_room:GetAspect( Feature.Shop ):SpawnShopOwner()
	local home = self:SpawnHome( shopkeep )

	table.insert( self.rooms, shop_room )
	return shop_room
end

function City:SpawnTavern()
	local room = Location.Tavern()
	self:SpawnLocation( room )

	local tavern = room:GainAspect( Feature.Tavern())

	local door = Object.Door()
	door:WarpToLocation( self:RandomRoad() )
	door:Connect( room )

	local rdoor = Object.Door()
	rdoor:WarpToLocation( room )
	rdoor:Connect( door.location )

	local barkeep = tavern:SpawnBarkeep()
	local home = self:SpawnHome( barkeep )

	table.insert( self.rooms, room )
end

function City:SpawnMilitary()
	local function GetName( room )
		return loc.format( "War Chambers of {1}", room:GetAspect( Aspect.Faction ):GetName() )
	end
	local room = Location()
	room:SetDetails( GetName, "An open room crammed with old tech and metal debris.")
	room:GainAspect( Feature.StrategicPoint() )
	room:GainAspect( Aspect.Faction( self.faction ))
	room:GainAspect( Aspect.BuildingTileMap( 16, 16 ))
	self:SpawnLocation( room )

	local door = Object.Door()
	door:WarpToLocation( self:RandomRoad() )
	door:Connect( room )

	local rdoor = Object.Door()
	rdoor:WarpToLocation( room )
	rdoor:Connect( door.location )

	local commander = Agent.Captain()
	commander:GainAspect( Aspect.Faction( self.faction ))
	commander:WarpToLocation( room )

	table.insert( self.rooms, room )
end

function City:RandomRoad()
	return self.worldgen:ArrayPick( self.roads )
end

function City:GetRoads()
	return self.roads
end
