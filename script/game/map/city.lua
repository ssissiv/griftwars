local City = class( "WorldGen.City", Entity )

function City:init()
	self.rooms = {}
	self.home_count = 0

	local left = WorldGen.Line( math.random( 12, 16 ), 0, 1 )
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
	
	local right = WorldGen.Line( math.random( 12, 16 ), 0, 1 )
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
	self:ConnectCorps()
	self:ConnectShops()
end

function City:ConnectHomes( line, block )
	for i, room in line:Rooms() do
		if math.random() < 0.4 then
			local home = Location()
			home:SetDetails( loc.format( "Residence #{1}{2}", block, i ), "This is somebody's residence." )
			home:SetImage( assets.LOCATION_BGS.INSIDE )
			home:GainAspect( Feature.Home( nil ) )
			home:Connect( room )
		end
	end
end

function City:ConnectCorps()
	for i = 1, 2 do
		local corp = WorldGen.CorpHQ()
		corp:GetEntrance():Connect( self:RandomRoom() )
		corp:SetCorpName( "Venture Corp" )
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
			shop_room:GainAspect( Feature.Shop( table.pick( SHOP_TYPE )))
			shop_room:Connect( room )
		end
	end
end


function City:RandomRoom()
	return table.arraypick( self.rooms )
end

function City:RoomAt( i )
	return self.rooms[ i ]
end
