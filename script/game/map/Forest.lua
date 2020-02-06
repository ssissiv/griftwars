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

	self:PopulateOrcs()
end

function Forest:OnSpawn( world )
	Forest._base.OnSpawn( self, world )

	world:SpawnLocation( self.rooms[1] )

	-- for i, room in ipairs( self.rooms ) do
	-- 	room:SetDetails( loc.format( "Thee Forest [{1}]", i ))
	-- end
end

function Forest:PopulateOrcs()
	local n = math.random( 3 )
	if n == 1 then
		-- Some Orcs
		n = math.ceil( #self.rooms / 5 )
	elseif n == 2 then
		-- LOTS of Orcs!
		n = math.ceil( #self.rooms / 3 )
	else
		-- No orcs!
		n = 0
	end
	for i = 1, n do
		local orc = Agent.Orc()
		orc:WarpToLocation( self:RandomRoom() )
	end
end

function Forest:CreateRoom()
	self.count = (self.count or 0) + 1
	local room = Location()
	room:SetDetails( loc.format( "The Forest [{1}]", self.count ), "A generic forest, this area abounds with trees, shrubs, and wildlife.")
	room:SetImage( assets.LOCATION_BGS.FOREST )
	if math.random() < 0.5 then
		room:GainAspect( Aspect.ScroungeTarget( QUALITY.POOR ) )
	end

	return room
end

function Forest:RandomRoom()
	return table.arraypick( self.rooms )
end

function Forest:RoomAt( i )
	return self.rooms[ i ]
end
