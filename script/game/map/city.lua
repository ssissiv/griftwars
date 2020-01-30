local City = class( "WorldGen.City", Entity )

function City:init()
	self.rooms = {}
	self.roads = {}
	self.home_count = 0

	local left = WorldGen.Line( math.random( 12, 16 ), 0, 1 )
	left:SetDetails( "The Junkyard West", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	left:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	table.arrayadd( self.rooms, left.rooms )
	table.arrayadd( self.roads, left.rooms )

	local top = WorldGen.Line( math.random( 8, 12 ), 1, 0 )
	top:SetDetails( "The Junkyard North", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	top:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	table.arrayadd( self.rooms, top.rooms )
	table.arrayadd( self.roads, top.rooms )
	
	local right = WorldGen.Line( math.random( 12, 16 ), 0, 1 )
	right:SetDetails( "The Junkyard East", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	right:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	table.arrayadd( self.rooms, right.rooms )
	table.arrayadd( self.roads, right.rooms )

	local bottom = WorldGen.Line( math.random( 8, 12 ), 1, 0 )
	bottom:SetDetails( "The Junkyard South", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	bottom:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	table.arrayadd( self.rooms, bottom.rooms )
	table.arrayadd( self.roads, bottom.rooms )
	
	-- Connect left and top
	local left_top = left:RoomAt( math.random( 1, 3 ) )
	local top_left = top:RoomAt( math.random( 1, 3 ) )
	left_top:Connect( top_left )

	-- Connect right and top
	local right_top = right:RoomAt( math.random( 1, 3 ))
	local top_right = top:RoomAt( top:RoomCount() - math.random( 1, 3 ))
	right_top:Connect( top_right )

	-- Connect right and bottom
	local right_bottom = right:RoomAt( right:RoomCount() - math.random( 1, 3 ))
	local bottom_right = bottom:RoomAt( bottom:RoomCount() - math.random( 1, 3 ))
	right_bottom:Connect( bottom_right )

	-- Connect bottom and left
	local left_bottom = left:RoomAt( left:RoomCount() - math.random( 1, 3 ))
	local bottom_left = bottom:RoomAt( math.random( 1, 3 ))
	left_bottom:Connect( bottom_left )

	-- Connect homes
	self:ConnectCorps()
	self:ConnectShops()
end

function City:OnSpawn( world )
	Entity.OnSpawn( self, world )

	for i, room in ipairs( self.rooms ) do
		world:SpawnLocation( room )
	end

	-- Junk heaps
	for i, road in ipairs( self.roads ) do
		if math.random() < 0.33 then
			road:SpawnEntity( Object.JunkHeap() )
		end
	end

	-- Shopkeepers
	for i, room in ipairs( self.rooms ) do
		local shop = room:GetAspect( Feature.Shop )
		if shop then
			local shopkeep = shop:SpawnShopOwner()
			if shopkeep then
				local home = self:SpawnHome( shopkeep )
			end
		end
	end	

	-- Scavengers
	local poor_house = self:SpawnHome()
	poor_house:SetDetails( "Under a Bridge" )
	for i = 1, 3 do
		local scavenger = world:SpawnAgent( Agent.Scavenger(), self:RandomRoad() )
		poor_house:GetAspect( Feature.Home ):AddResident( scavenger )
	end
end

function City:SpawnHome( resident )

	local room = Location()
	room:SetDetails( loc.format( "Residence #{1}", #self.rooms ), "This is somebody's residence." )
	room:SetImage( assets.LOCATION_BGS.INSIDE )
	local home = room:GainAspect( Feature.Home() )
	if resident then
		home:AddResident( resident )
	end
	room:Connect( self:RandomRoad() )

	table.insert( self.rooms, room )
	return room
end

function City:ConnectCorps()
	for i = 1, 2 do
		local corp = WorldGen.CorpHQ()
		corp:GetEntrance():Connect( self:RandomRoad() )
		corp:SetCorpName( "Venture Corp" )
		table.arrayadd( self.rooms, corp.rooms )
	end
end

function City:ConnectShops()
	for i = 1, 10 do
		local room = self:RandomRoad()
		if room:HasAspect( Feature.Home ) then
			--
			error()
		else
			local shop_room = Location()
			shop_room:SetImage( assets.LOCATION_BGS.SHOP )
			shop_room:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))
			shop_room:Connect( room )
			table.insert( self.rooms, shop_room )
		end
	end
end

function City:RandomRoad()
	return table.arraypick( self.roads )
end

function City:RoomAt( i )
	return self.rooms[ i ]
end
