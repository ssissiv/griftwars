local City = class( "WorldGen.City", Entity )

function City:init( worldgen )
	self.worldgen = worldgen
	self.rooms = {}
	self.roads = {}
	self.home_count = 0

	-- local left = WorldGen.Line( math.random( 12, 16 ), EXIT.NORTH )
	-- left:SetDetails( "The Junkyard West", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	-- left:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	-- table.arrayadd( self.rooms, left.rooms )
	-- table.arrayadd( self.roads, left.rooms )

	-- local top = WorldGen.Line( math.random( 8, 12 ), EXIT.EAST )
	-- top:SetDetails( "The Junkyard North", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	-- top:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	-- table.arrayadd( self.rooms, top.rooms )
	-- table.arrayadd( self.roads, top.rooms )
	-- print(tostr(top:RoomAt(1).exits))
	
	-- local right = WorldGen.Line( math.random( 12, 16 ), EXIT.SOUTH )
	-- right:SetDetails( "The Junkyard East", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	-- right:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	-- table.arrayadd( self.rooms, right.rooms )
	-- table.arrayadd( self.roads, right.rooms )

	-- local bottom = WorldGen.Line( math.random( 8, 12 ), EXIT.WEST )
	-- bottom:SetDetails( "The Junkyard South", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	-- bottom:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	-- table.arrayadd( self.rooms, bottom.rooms )
	-- table.arrayadd( self.roads, bottom.rooms )
	
	-- -- Connect left and top
	-- local left_top = left:RoomAt( math.random( 1, 3 ) )
	-- local top_left = top:RoomAt( 1 )
	-- left_top:Connect( top_left, EXIT.EAST )

	-- -- Connect right and top
	-- local right_top = right:RoomAt( math.random( 1, 3 ) )
	-- local top_right = top:RoomAt( top:RoomCount() )
	-- right_top:Connect( top_right, EXIT.WEST )

	-- -- Connect right and bottom
	-- local right_bottom = right:RoomAt( right:RoomCount() - math.random( 1, 3 ))
	-- local bottom_right = bottom:RoomAt( 1 )
	-- right_bottom:Connect( bottom_right, EXIT.WEST )

	-- -- Connect bottom and left
	-- local left_bottom = left:RoomAt( left:RoomCount() )
	-- local bottom_left = bottom:RoomAt( left:RoomCount() - math.random( 1, 3 ))
	-- left_bottom:Connect( bottom_left, EXIT.SOUTH )

	-- -- Connect homes
	-- self:ConnectCorps()
	-- self:ConnectShops()
end

function City:OnSpawn( world )
	Entity.OnSpawn( self, world )

	-- Origin.
	local road = self:CreateRoad()
	road:SetCoordinate( 0, 0 )
	world:SpawnLocation( road )
	table.insert( self.roads, road )

	local function MakeCity( location )
		location:SetDetails( "City Road", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
		location:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
		table.insert( self.roads, location )

		if math.random() < 0.33 then
			Object.JunkHeap():WarpToLocation( location )
		end
	end

	self.worldgen:SproutLocations( road, 8, MakeCity )

	-- Shops
	for i = 1, 3 do
		self:SpawnShop()
	end	

	-- Scavengers
	local poor_house = self.worldgen:Sprout( self:RandomAvailableRoad(), function( location )
			location:GainAspect( Feature.Home() )
			location:SetDetails( "Under a Bridge" )
		end )
	assert( poor_house )
	assert( poor_house:GetAspect( Feature.Home ) ~= nil )


	for i = 1, 3 do
		local scavenger = world:SpawnAgent( Agent.Scavenger(), self:RandomRoad() )
		poor_house:GetAspect( Feature.Home ):AddResident( scavenger )
	end

	-- Snoops
	for i = 1, 2 do
		local snoop = world:SpawnAgent( Agent.Snoop(), poor_house )
		poor_house:GetAspect( Feature.Home ):AddResident( snoop )
	end
end

function City:CreateRoad()
	local road = Location()
	road:SetDetails( "City Road", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	road:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )

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

function City:ConnectCorps()
	for i = 1, 2 do
		local corp = WorldGen.CorpHQ()
		corp:GetEntrance():Connect( self:RandomRoad() )
		corp:SetCorpName( "Venture Corp" )
		table.arrayadd( self.rooms, corp.rooms )
	end
end

function City:RandomAvailableRoad()
	local roads = {}
	for i, road in ipairs( self.roads ) do
		if road:CountAvailableExits() > 0 then
			table.insert( roads, road )
		end
	end
	return table.arraypick( roads )
end

function City:RandomRoad()
	return table.arraypick( self.roads )
end

function City:RoomAt( i )
	return self.rooms[ i ]
end
