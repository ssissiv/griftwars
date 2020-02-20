local WorldGen = class( "WorldGen" )

function WorldGen:init( world )
	self.world = world
	-- self.rng = love.math.newRandomGenerator( 3418323524, 20529293 )
	self.rng = love.math.newRandomGenerator( 5235235, 120912 )
	print( "WorldGen seeds:", self.rng:getSeed() )
end

function WorldGen:Random( a, b )
	if a == nil and b == nil then
		return self.rng:random()
	elseif b == nil then
		return self.rng:random( a )
	else
		return self.rng:random( a, b )
	end
end

function WorldGen:ArrayPick( t )
	return t[ self:Random( #t ) ]
end

function WorldGen:Sprout( room, fn, ... )
	if room == nil then
		return
	end

	local exits = table.shallowcopy( room.available_exits )
	while #exits > 0 do
		local exit = table.remove( exits, self:Random( #exits ))
		local x, y = room:GetCoordinate()
		x, y = OffsetExit( x, y, exit )

		local adj = self.world:GetLocationAt( x, y )
		if adj == nil then
			local new_room = Location()
			fn( new_room, ... )
			room:Connect( new_room, exit )
			return new_room
		end
	end

	-- print( "COULD NOT SPROUT FROM", room, tostr(room.available_exits), debug.traceback() )
end

function WorldGen:SproutLocations( start, max_count, fn, ... )
	assert( is_instance( start, Location ))
	local locations = {}
	local stack = { start }

	while max_count > #locations and #stack > 0 do
		local room = stack[ #stack ]
		local new_room = self:Sprout( room, fn, ... )
		if new_room then
			--
			table.insert( stack, new_room )
			table.insert( locations, new_room )
		else
			table.remove( stack )
		end
	end

	if #locations < max_count then
		print( string.format( "only spawned %d/%d locations", #locations, max_count ))
		print( start, start:GetCoordinate() )
		print( debug.traceback() )
	end

	local p = 0.5
	for i, room in ipairs( locations ) do
		local x, y = room:GetCoordinate()
		for i, exit in ipairs( room.available_exits ) do
			local x1, y1 = OffsetExit( x, y, exit )
			local adj = self.world:GetLocationAt( x1, y1 )
			if adj and table.contains( locations, adj ) then
				if self:Random() < p then
					room:Connect( adj, exit )
				end
			end
		end
	end
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


	local city = WorldGen.City( self )
	city:GenerateCity( nil, 6 )
	
	--------------------------------------------------------------------------------------
	-- Forest!

	for i = 1, 2 do
		local origin = self:RandomAvailableLocation( city:GetRoads(), 6 )
		if origin then
			local forest = WorldGen.Forest( self )
			world:SpawnEntity( forest )
			forest:Generate( origin, 6 )
			forest:PopulateOrcs()

			local city_origin = self:RandomAvailableLocation( forest:GetRooms(), 6 )
			if city_origin then
				local city = WorldGen.City( self )
				city:GenerateCity( city_origin, 6 )
			end
		end
	end

	--------------------------------------------------------------------------------------

	local player = self:GeneratePlayer( self.world )
	world:SpawnAgent( player, city:RandomRoad() )

	--------------------------------------------------------------------------------------

	return self.world
end

function WorldGen:GeneratePlayer( world )

	local player = Agent()
	player:SetDetails( "Han", nil, GENDER.MALE )
	-- player:GainAspect( Skill.Scrounge() )
	-- player:GainAspect( Skill.Socialize() )
	-- player:GainAspect( Skill.RumourMonger() )
	player:GainAspect( Aspect.Player() )
	player:GainAspect( Aspect.Combat() )
	player:GainAspect( Verb.Scrounge( player ) )

	local tokens = player:GainAspect( Aspect.TokenHolder() )
	tokens:AddToken( Token( DIE_FACE.DIPLOMACY, 1 ) )
	tokens:AddToken( Token( DIE_FACE.STEALTH, 1 ) )
	tokens:AddToken( Token( DIE_FACE.POWER, 1 ) )

	player:CreateStat( STAT.XP, 0, 100 )

	player:GetInventory():DeltaMoney( 1 )
	return player
end
