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

	-- local e = WorldMap.CondensedGrid( 5, 5 )
	-- e:RandomRoom():Connect( start )
	-- world:SpawnEnvironment( e )

	local hood = Location()
	hood:SetDetails( "The Junkyard Strip", "These dilapidated streets are home to all manner of detritus. Some of it walks on two legs.")
	hood:Connect( start )
	world:SpawnLocation( hood )

	local player = Agent()
	player:SetFlags( Agent.FLAGS.PLAYER )
	player:SetDetails( "Han", nil, GENDER.MALE )
	player:GainAspect( Skill.Scrounge() )
	player:GainAspect( Skill.Socialize() )
	player:GainAspect( Skill.RumourMonger() )
	player:GainAspect( Trait.Memory() )
	player:GainAspect( Trait.Player() ):AddDefaultDice()
	player:GetInventory():DeltaMoney( 1 )
	world:SpawnAgent( player, start )

	local NAMES = { "Bodie", "Ger", "Fry" }

	for i = 1, 3 do
		local other = Agent()
		other:SetDetails( NAMES[ i ], "Here's a guy.", GENDER.MALE )
		other:GainAspect( Trait.Cowardly() )
		other:GainAspect( Trait.Poor() )
		other:GainAspect( Skill.Scrounge() )
		other:GainAspect( Skill.RumourMonger() ):GainInfo( INFO.LOCAL_NEWS, 3 )
		world:SpawnAgent( other, start )
	end
end
