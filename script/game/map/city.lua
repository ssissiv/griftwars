local City = class( "WorldGen.City", Entity )

function City:init( worldgen )
	self.worldgen = worldgen
	self.world = worldgen.world
	self.rooms = {}
	self.roads = {}
	self.home_count = 0
end

function City:GenerateCity( origin, sz )
	local world = self.world

	self.name = world:GetAspect( Aspect.CityNamePool ):PickName()

	if origin == nil then
		origin = self:SpawnRoad()
	end

	self.worldgen:SproutLocations( origin, sz, function( location ) self:SpawnRoad( location ) end )

	-- Shops
	for i = 1, 3 do
		self:SpawnShop()
	end	

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

	local structure = Structure()
	structure:WarpToLocation( self:RandomRoad() )
	structure:Connect( room )

	table.insert( self.rooms, room )
	return room
end

function City:SpawnShop()
	local shop_room = Location()
	shop_room:SetImage( assets.LOCATION_BGS.SHOP )
	local shop = shop_room:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))

	local structure = Structure()
	structure:WarpToLocation( self:RandomRoad() )
	structure:Connect( shop_room )

	local shopkeep = shop:SpawnShopOwner()
	local home = self:SpawnHome( shopkeep )

	table.insert( self.rooms, shop_room )
	return shop_room
end

function City:SpawnTavern()
	local tavern = Location()
	tavern:SetImage( assets.LOCATION_BGS.SHOP )
	tavern:GainAspect( Feature.Tavern())

	local structure = Structure()
	structure:WarpToLocation( self:RandomRoad() )
	structure:Connect( tavern )

	local barkeep = tavern:SpawnBarkeep()
	local home = self:SpawnHome( barkeep )

	table.insert( self.rooms, tavern )
end


function City:GenerateMilitary( world )
	local room = Location()
	room:SetDetails( "Command Room", "An open room crammed with old tech and metal debris.")
	world:SpawnLocation( room )

	local commander = Agent.MilitiaCaptain()
	commander:WarpToLocation( room )
end

function City:RandomRoad()
	return self.worldgen:ArrayPick( self.roads )
end

function City:GetRoads()
	return self.roads
end

function City:RoomAt( i )
	return self.rooms[ i ]
end
