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

	local origin = self.origin or self:SpawnRoad()
	self.worldgen:SproutLocations( origin, self.size, function( location ) self:SpawnRoad( location ) end )

	-- Shops
	for i = 1, 1 do
		self:SpawnShop()
	end

	self:SpawnTavern()
	self:SpawnMilitary()

	-- Scavengers
	local poor_house = self.worldgen:Sprout( self.worldgen:RandomAvailableLocation( self.roads, 1 ), function( location )
			location:GainAspect( Feature.Home() )
			location:SetDetails( "Under a Bridge" )
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

function City:SpawnRoad( road )
	if road == nil then
		road = Location()
		road:SetCoordinate( 0, 0 )
		self.world:SpawnLocation( road )
	end

	road:SetDetails( loc.format( "City of {1}", self.name), "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	road:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )

	table.insert( self.roads, road )
	table.insert( self.rooms, road )

	if self.worldgen:Random() < 0.2 then
		Object.JunkHeap():WarpToLocation( road )
	end

	return road
end

function City:SpawnHome( resident )
	local room = Location()
	room:SetDetails( loc.format( "Residence #{1}", #self.rooms ), "This is somebody's residence." )
	room:SetImage( assets.LOCATION_BGS.INSIDE )
	local home = room:GainAspect( Feature.Home() )
	if resident then
		home:AddResident( resident )
	end

	local door = Object.Door()
	door:WarpToLocation( self:RandomRoad() )
	door:Connect( room )

	table.insert( self.rooms, room )
	return room
end

function City:SpawnShop()
	local shop_room = Location.Shop()
	self.world:SpawnLocation( shop_room )

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
	local room = Location()
	room:SetImage( assets.LOCATION_BGS.SHOP )
	self.world:SpawnLocation( room )

	local tavern = room:GainAspect( Feature.Tavern())

	local door = Object.Door()
	door:WarpToLocation( self:RandomRoad() )
	door:Connect( room )

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
	self.world:SpawnLocation( room )

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
