local WorldGen = class( "WorldGen" )

function WorldGen:init()
end

function WorldGen:Sprout( room, fn, ... )
	local exits = table.shallowcopy( room.available_exits )
	while #exits > 0 do
		local exit = table.remove( exits, math.random( #exits ))
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

	print( "COULD NOT SPROUT FROM", room, tostr(room.available_exits), debug.traceback() )
	DBG(room)
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
			-- Is there a connecting room?
			-- local exits = table.shallowcopy( room.available_exits )
			-- for i = #exits, 1, -1 do
			-- 	if not table.contains( locations, exits[i] ) then
			-- 		table.remove( exits, i )
			-- 	end
			-- end

			-- local adj = table.arraypick( exits )
			-- if adj then
			-- 	room:Connect( adj, )

			table.remove( stack )
		end
	end
end

function WorldGen:GenerateWorld()
	local world = World()
	self.world = world

	Msg:SetWorld( world )


	local city = WorldGen.City( self )
	world:SpawnEntity( city )
	
	local start = self:Sprout( city:RandomAvailableRoad(), function( location )
		location:SetDetails( "Your Home", "This is your home. It's pretty chill." )
		location:SetImage( assets.LOCATION_BGS.HOME )
		location:GainAspect( Feature.Home() )
	end )

	local shop = self:Sprout( city:RandomAvailableRoad(), function( shop )
		shop:SetDetails( "Shady Sundries", "Little more than ramshackle shed, this carved out nook in the debris is a popular shop.")
		shop:GainAspect( Feature.Shop( SHOP_TYPE.GENERAL ) )
		shop.map_colour = constants.colours.SHOP_TILE
	end )
	
	local shopkeep = Agent.Shopkeeper()
	shopkeep:SetDetails( "Armitage", "Dude with lazr-glass vizors, and a knife in every pocket.", GENDER.MALE )
	shopkeep:GetAspect( Job.Shopkeep ):AssignShop( shop )
	shopkeep:WarpToLocation( shop )
	
	local collector = Agent.Collector()
	shopkeep:SetDetails( "Gerin", "Always searching. Is it something he seeks, or something he yearns to know?", GENDER.MALE )	
	world:SpawnAgent( collector, shop )

	-- Gerin meets Armitage to identify any unknown items he's scavenged.
	-- Armitage gets free Scrap.
	-- world:SpawnRelationship( Relationship.ArmitageGerin( shopkeep, collector ) )


	-- self:GenerateMilitary( world )

	--------------------------------------------------------------------------------------
	-- Forest!

	for i = 1, 2 do
		local forest = WorldGen.Forest( self )
		world:SpawnEntity( forest )
		forest:Generate( city:RandomAvailableRoad(), 6 )
		forest:PopulateOrcs()
	end

	--------------------------------------------------------------------------------------

	local player = self:GeneratePlayer( self.world )
	world:SpawnAgent( player, start )
	if start then
		start:GetAspect( Feature.Home ):AddResident( player )
	end

	--------------------------------------------------------------------------------------

	return self.world
end

function WorldGen:GenerateMilitary( world )
	local room = Location()
	room:SetDetails( "Command Room", "An open room crammed with old tech and metal debris.")
	world:SpawnLocation( room )

	local commander = Agent.MilitiaCaptain()
	commander:WarpToLocation( room )
end

function WorldGen:GeneratePlayer( world )

	local player = Agent()
	player:SetDetails( "Han", nil, GENDER.MALE )
	-- player:GainAspect( Skill.Scrounge() )
	-- player:GainAspect( Skill.Socialize() )
	-- player:GainAspect( Skill.RumourMonger() )
	player:GainAspect( Trait.Player() )
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
