local WorldGen = class( "WorldGen" )

function WorldGen.MatchWorldGenTag( match_tag, tagstr )
	local tags = tagstr and tagstr:split( " " )
	if tags == nil or #tags == 0 then
		return false
	end
	local our_tags = match_tag and match_tag:split( " " )
	if our_tags == nil or #our_tags == 0 then
		return false
	end

	-- All incoming tags must match.
	for i, tag in ipairs( tags ) do
		tag = MATCH_TAGS[ tag ] or tag
		if not table.contains( our_tags, tag ) then
			return false
		end
	end

	-- All our tags must match to incoming.
	for i, tag in ipairs( our_tags ) do
		tag = MATCH_TAGS[ tag ] or tag
		if not table.contains( tags, tag ) then
			return false
		end
	end

	return true
end

function WorldGen:init( world )
	self.world = world
end

function WorldGen:Random( a, b )
	return self.world:Random( a, b )
end

function WorldGen:ArrayPick( t )
	return self.world:ArrayPick( t )
end

function WorldGen:WeightedPick( t )
	return self.world:WeightedPick( t )
end

function WorldGen:GenerateTinyWorld()
	local world = World()
	self.world = world

	Msg:SetWorld( world )

	local origin = Location.JunkYard()
	origin:SetDetails( "Tiny World", "Not much here." )
	origin:SetCoordinate( 0, 0 )
	world:SpawnLocation( origin )

	local player = Agent.Grifter()
	world:SpawnAgent( player, origin )

	return world

end

function WorldGen:GenerateWorld()
	assert( self.world == nil )

	local world = World()
	self.world = world

	Msg:SetWorld( world )


	local city = Zone.City( self, 3, 0 )
	world:SpawnEntity( city )

	local zones = { city }
	local zone_count = 0
	while #zones > 0 and zone_count < 12 do
		local zone = table.remove( zones, 1 )
		for i, exit in ipairs( EXIT_ARRAY ) do
			local exit_tag = EXIT_TAG[ exit ]
			local portal = zone:RandomUnusedPortal( "boundary "..exit_tag )
			local class_name = zone:RandomZoneClass()
			local zone_class = CLASSES[ class_name ]
			if portal and zone_class then
				local new_zone = zone_class( self, 3, zone:GetZoneDepth() + 1, portal )
				world:SpawnEntity( new_zone )
				table.insert( zones, new_zone )
				zone_count = zone_count + 1
			end
		end
	end
	
	----------------------------------------------------------------------------------------------------
	-- Multi-pass zone generation phase -- let each zone do what it needs to do in any number of passes.

	local zones = world:GetBucketByClass( Zone )
	local passes = 0
	while passes < 99 do
		local changed = 0
		for i, zone in ipairs( zones ) do
			if zone.OnWorldGenPass and zone:OnWorldGenPass( passes ) then
				changed = changed + 1
			end
		end
		if changed == 0 then
			print( "WorldGen: done after ", passes, " passes." )
			break
		end
		passes = passes + 1
	end

	--------------------------------------------------------------------------------------
	-- Place the player.

	local player = Agent.Grifter()
	world:SpawnAgent( player, city:RandomRoom() )

	--------------------------------------------------------------------------------------

	print( table.count( world:GetBucketByClass( Zone ) ), " total zones." )

	return self.world
end
