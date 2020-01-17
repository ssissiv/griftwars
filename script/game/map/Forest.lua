local Forest = class( "WorldGen.Forest", Entity )

function Forest:init()
	self.rooms = {}

	local max_rooms = math.random( 10, 30 )
	local open = { self:CreateRoom() }
	while #open > 0 do
		local room = table.remove( open, 1 )

		local maxn = math.min( 3, max_rooms - (#open + #self.rooms) )
		local n = math.random( 1, 3 )
		for i = 1, math.min( n, maxn ) do
			local neighbour = self:CreateRoom()
			neighbour:Connect( room )
			table.insert( open, neighbour )
		end

		if #self.rooms > 0 and math.random() < 0.2 then
			local r = self:RandomRoom()
			if not room:IsConnected( r ) then
				room:Connect( r )
			end
		end

		table.insert( self.rooms, room )
	end
end

function Forest:OnSpawn( world )
	print( "FOREST", #self.rooms )
	-- for i, room in ipairs( self.rooms ) do
	-- 	room:SetDetails( loc.format( "Thee Forest [{1}]", i ))
	-- end
end

function Forest:CreateRoom()
	self.count = (self.count or 0) + 1
	local room = Location()
	room:SetDetails( loc.format( "The Forest [{1}]", self.count ), "A generic forest, this area abounds with trees, shrubs, and wildlife.")
	room:SetImage( assets.LOCATION_BGS.FOREST )
	if math.random() < 0.5 then
		room:GainAspect( Aspect.ScroungeTarget() )
	end

	return room
end

function Forest:RandomRoom()
	return table.arraypick( self.rooms )
end

function Forest:RoomAt( i )
	return self.rooms[ i ]
end
