local WorldGen = class( "WorldGen" )

function WorldGen:init( world )
	self.world = world
end

function WorldGen:Random( a, b )
	return self.world:Random( a, b )
end

function WorldGen:ArrayPick( t )
	return self.world:ArrayPick( t )
end

function WorldGen:TablePick( t )
	return self.world:TablePick( t )
end

local function FindCoordinate( coords, x, y )
	for i = 1, #coords, 2 do
		if coords[i] == x and coords[i+1] == y then
			return i
		end
	end
end

function WorldGen:CountSpace( x, y, max_count )
	local open = { x, y }
	local closed = {}
	local count = 0

	while #open > 0 and count < max_count do
		local x = table.remove( open, 1 )
		local y = table.remove( open, 1 )

		table.insert( closed, x )
		table.insert( closed, y )

		local room = self.world:GetLocationAt( x, y )
		if room == nil then
			count = count + 1

			for i, exit in ipairs( EXIT_ARRAY ) do
				local x1, y1 = OffsetExit( x, y, exit )
				if not FindCoordinate( open, x1, y1 ) and not FindCoordinate( closed, x1, y1 ) then
					table.insert( open, x1 )
					table.insert( open, y1 )
				end
			end
		end
	end

	return count
end

function WorldGen:RandomAvailableLocation( locations, spaces )
	spaces = spaces or 1
	local available = {}
	for i, room in ipairs( locations ) do
		local x, y = room:GetCoordinate()
		for i, exit in ipairs( room.available_exits ) do
			local x1, y1 = OffsetExit( x, y, exit )
			if self:CountSpace( x1, y1, spaces ) >= spaces then
				table.insert( available, room )
			end
		end
	end
	return self:ArrayPick( available )
end


function WorldGen:GenerateTinyWorld()
	local world = World()
	self.world = world

	Msg:SetWorld( world )

	local origin = Location()
	origin:SetDetails( "Tiny World", "Not much here." )
	origin:SetCoordinate( 0, 0 )

	local player = self:GeneratePlayer( self.world )
	world:SpawnAgent( player, origin )

	return world

end

function WorldGen:GenerateWorld()
	assert( self.world == nil )

	local world = World()
	self.world = world

	Msg:SetWorld( world )

	local city = WorldGen.City( self, nil, 1 )
	world:SpawnEntity( city )
	
	--------------------------------------------------------------------------------------
	-- Forest!

	-- local wilderness = {
	-- 	[10] = WorldGen.Forest,
	-- 	[5] = WorldGen.Hills,
	-- 	[3] = WorldGen.Mountains,
	-- }

	-- for i = 1, 3 do
	-- 	local origin = self:RandomAvailableLocation( city:GetRoads(), 6 )
	-- 	if origin then
	-- 		local wt, zone_class = self:TablePick( wilderness )
	-- 		local forest = zone_class( self, origin, 6 )
	-- 		world:SpawnEntity( forest )

	-- 		local city_origin = self:RandomAvailableLocation( forest:GetRooms(), 6 )
	-- 		if city_origin then
	-- 			local city = WorldGen.City( self, city_origin, 1 )
	-- 			world:SpawnEntity( city )
	-- 		end
	-- 	end
	-- end

	--------------------------------------------------------------------------------------
	-- Place the player.

	local player = self:GeneratePlayer( self.world )
	world:SpawnAgent( player, city:RandomRoad() )

	--------------------------------------------------------------------------------------

	local zones = world:CreateBucketByClass( Zone )
	print( table.count( zones ), " total zones." )

	return self.world
end

function WorldGen:GeneratePlayer( world )

	local player = Agent()
	player.MAP_CHAR = "@"
	player:SetDetails( "Han", nil, GENDER.MALE )
	player:GainAspect( Aspect.Player() )
	player:GainAspect( Aspect.Combat() )
	player:GainAspect( Aspect.Impass() )

	local tokens = player:GainAspect( Aspect.TokenHolder() )
	tokens:AddToken( Token( DIE_FACE.DIPLOMACY, 1 ) )
	tokens:AddToken( Token( DIE_FACE.STEALTH, 1 ) )
	tokens:AddToken( Token( DIE_FACE.POWER, 1 ) )

	player:CreateStat( STAT.XP, 0, 100 )

	player:GetInventory():DeltaMoney( 10 )
	return player
end
