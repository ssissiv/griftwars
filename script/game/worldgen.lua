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
	world:SpawnLocation( start )

	local hood = Location()
	hood:SetDetails( "The Junkyard Strip", "These dilapidated streets are home to all manner of detritus. Some on two legs.")
	world:SpawnLocation( hood )

	Location.Connect( start, hood )

	local player = Agent()
	player:SetFlags( Agent.FLAGS.PLAYER )
	player:SetDetails( "Han" )
	player:GainAspect( Skill.Scrounge() )
	player:GainAspect( Skill.Socialize() )
	player:GetInventory():DeltaMoney( 1 )
	world:SpawnAgent( player )

	local other = Agent()
	other:SetDetails( "Kevin", "Here's a guy." )
	other:GainAspect( Trait.Cowardly() )
	other:GainAspect( Trait.Poor() )
	other:GainAspect( Skill.Scrounge() )
	world:SpawnAgent( other )

	player:MoveToLocation( start )
	other:MoveToLocation( start )
end
