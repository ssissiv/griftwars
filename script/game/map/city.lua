local City = class( "WorldGen.City" )

function City:init()
	self.rooms = {}
	self.adjectives = Aspect.NamePool( "data/adjectives.txt" )
	self.nouns = Aspect.NamePool( "data/nouns.txt" )
	self.home_count = 0

	local left = WorldGen.Line( math.random( 8, 12 ), 0, 1 )
	left:SetDetails( "The Junkyard West", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	left:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	for i, room in left:Rooms() do
		room:GainAspect( Aspect.ScroungeTarget() )
	end
	table.arrayadd( self.rooms, left.rooms )

	local top = WorldGen.Line( math.random( 8, 12 ), 1, 0 )
	top:SetDetails( "The Junkyard North", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	top:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	for i, room in top:Rooms() do
		room:GainAspect( Aspect.ScroungeTarget() )
	end
	table.arrayadd( self.rooms, top.rooms )
	
	local right = WorldGen.Line( math.random( 8, 12 ), 0, 1 )
	right:SetDetails( "The Junkyard East", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	right:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	for i, room in right:Rooms() do
		room:GainAspect( Aspect.ScroungeTarget() )
	end
	table.arrayadd( self.rooms, right.rooms )
	
	local bottom = WorldGen.Line( math.random( 8, 12 ), 1, 0 )
	bottom:SetDetails( "The Junkyard South", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	bottom:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	for i, room in bottom:Rooms() do
		room:GainAspect( Aspect.ScroungeTarget() )
	end
	table.arrayadd( self.rooms, bottom.rooms )
	
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
	self:ConnectHomes( left, 1 )
	self:ConnectHomes( top, 2 )
	self:ConnectHomes( right, 3 )
	self:ConnectHomes( bottom, 4 )
	self:ConnectShops()
end

function City:ConnectHomes( line, block )
	for i, room in line:Rooms() do
		if math.random() < 0.3 then
			local home = Location()
			home:SetDetails( loc.format( "Residence #{1}{2}", block, i ), "This is somebody's residence." )
			home:SetImage( assets.LOCATION_BGS.INSIDE )
			home:GainAspect( Feature.Home( nil ) )
			home:Connect( room )
		end
	end
end


function City:ConnectShops()
	for i = 1, 10 do
		local room = self:RandomRoom()
		if room:HasAspect( Feature.Home ) then
			--
		else
			local shop_room = Location()
			shop_room:SetImage( assets.LOCATION_BGS.SHOP )
			shop_room:Connect( room )
			local adj = self.adjectives:PickName()
			local noun = self.nouns:PickName()
			local stock = {}

			local shop_type = table.pick( SHOP_TYPE )
			if shop_type == SHOP_TYPE.GENERAL then
				local name = loc.format( "The {1} {2} General Store", adj, noun )
				shop_room:SetDetails( name, "A general store." )

			elseif shop_type == SHOP_TYPE.FOOD then
				local name = loc.format( "The {1} {2} Restaurant", adj, noun )
				shop_room:SetDetails( name, "A restaurant." )

			elseif shop_type == SHOP_TYPE.EQUIPMENT then
				local name = loc.format( "The {1} {2} Weapons n Arms", adj, noun )
				shop_room:SetDetails( name, "An equipment store." )
				table.insert( stock, Weapon.Dirk() )
			end

			local shopkeep = Agent.Shopkeeper()
			shopkeep:WarpToLocation( shop_room )
			local shop = shopkeep:GetAspect( Aspect.Shopkeep )
			shop:AssignShop( shop_room )
			for i, obj in ipairs( stock ) do
				shop:AddShopItem( obj )
			end
		end
	end
end


function City:RandomRoom()
	return table.arraypick( self.rooms )
end

function City:RoomAt( i )
	return self.rooms[ i ]
end
