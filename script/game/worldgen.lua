local WorldGen = class( "WorldGen" )

function WorldGen:init()
end

function WorldGen:GenerateWorld()
	local world = World()
	self.world = world

	Msg:SetWorld( world )

	local start = Location()
	start:SetDetails( "Your Home", "This is your home. It's pretty chill." )
	start:SetImage( assets.LOCATION_BGS.HOME )
	world:SpawnLocation( start )

	local city = WorldGen.City()
	city:RoomAt( 1 ):Connect( start )
	
	local shop = Location()
	shop:SetDetails( "Shady Sundries", "Little more than ramshackle shed, this carved out nook in the debris is a popular shop.")
	shop:Connect( city:RandomRoom() )
	
	local dens = Location()
	dens:SetDetails( "The Dens", "Nobody visits these ruins, for they are overrun with feral vrocs." )
	dens:Connect( city:RandomRoom() )

	local shopkeep = Agent.GeneralStoreOwner()
	shopkeep:SetDetails( "Armitage", "Dude with lazr-glass vizors, and a knife in every pocket.", GENDER.MALE )
	shopkeep:GetAspect( Aspect.Shopkeep ):AssignShop( shop )
	world:SpawnAgent( shopkeep, shop )


	local collector = Agent.Collector()
	shopkeep:SetDetails( "Gerin", "Always searching. Is it something he seeks, or something he yearns to know?", GENDER.MALE )	
	world:SpawnAgent( collector, shop )

	-- Gerin meets Armitage to identify any unknown items he's scavenged.
	-- Armitage gets free Scrap.
	world:SpawnRelationship( Relationship.ArmitageGerin( shopkeep, collector ) )

	for i = 1, 3 do
		local scavenger = world:SpawnAgent( Agent.Scavenger(), start )
		world:SpawnRelationship( Relationship.Subordinate( collector, scavenger ))
	end

	self:GenerateMilitary( world )

	local player = self:GeneratePlayer( self.world )
	world:SpawnAgent( player, start )
	start:GainAspect( Feature.Home( player ) )

	return self.world
end

function WorldGen:GenerateMilitary( world )
	local room = Location()
	room:SetDetails( "Command Room", "An open room crammed with old tech and metal debris.")

	local commander = world:SpawnAgent( Agent.MilitiaCaptain(), room )
	DBG(commander)
end

function WorldGen:GeneratePlayer( world )

	local player = Agent()
	player:SetDetails( "Han", nil, GENDER.MALE )
	-- player:GainAspect( Skill.Scrounge() )
	-- player:GainAspect( Skill.Socialize() )
	-- player:GainAspect( Skill.RumourMonger() )
	player:GainAspect( Trait.Memory() )
	player:GainAspect( Trait.Player() )
	local tokens = player:GainAspect( Aspect.TokenHolder() )
	tokens:AddToken( Token( DIE_FACE.DIPLOMACY, 1 ) )
	tokens:AddToken( Token( DIE_FACE.STEALTH, 1 ) )
	tokens:AddToken( Token( DIE_FACE.POWER, 1 ) )

	player:CreateStat( STAT.XP, 0, 100 )

	player:GetInventory():DeltaMoney( 1 )
	return player
end
