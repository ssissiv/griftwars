local WorldGen = class( "WorldGen" )

function WorldGen:init()
end

function WorldGen:GenerateWorld()
	self.world = World()

	self:GeneratePlayer( self.world )

	return self.world
end

function WorldGen:GeneratePlayer( world )
	local start = Location()
	start:SetDetails( "Your Home", "This is your home. It's pretty chill." )
	start:SetImage( assets.LOCATION_BGS.HOME )
	world:SpawnLocation( start )

	local hood = WorldGen.Line( 5 )
	hood:SetDetails( "The Junkyard Strip", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	hood:SetImage( assets.LOCATION_BGS.JUNKYARD_STRIP )
	hood:RoomAt( 1 ):Connect( start )

	local shop = Location()
	shop:SetDetails( "Shady Sundries", "Little more than ramshackle shed, this carved out nook in the debris is a popular shop.")
	shop:Connect( hood:RoomAt( 2 ))
	
	local dens = Location()
	dens:SetDetails( "The Dens", "Nobody visits these ruins, for they are overrun with feral vrocs." )
	dens:Connect( hood:RoomAt( 5 ))

	local shopkeep = Agent()
	shopkeep:SetDetails( "Armitage", "Dude with lazr-glass vizors, and a knife in every pocket.", GENDER.MALE )
	world:SpawnAgent( shopkeep, shop )

	local collector = Agent.Collector()
	world:SpawnAgent( collector, shop )


	local player = Agent()
	player:SetDetails( "Han", nil, GENDER.MALE )
	-- player:GainAspect( Skill.Scrounge() )
	-- player:GainAspect( Skill.Socialize() )
	-- player:GainAspect( Skill.RumourMonger() )
	player:GainAspect( Trait.Memory() )
	player:GainAspect( Trait.Player() ):AddDefaultDice()
	player:GetInventory():DeltaMoney( 1 )
	world:SpawnAgent( player, start )

	for i = 1, 3 do
		local scavenger = world:SpawnAgent( Agent.Scavenger(), start )
		collector:GetAspect( Trait.Collector ):AddFollower( scavenger )
	end
end
