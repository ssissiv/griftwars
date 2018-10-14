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
	world:AddLocation( start )

	local hood = Location()
	hood:SetDetails( "The Junkyard Strip", "These dilapidated streets are home to all manner of detritus. Some on two legs.")
	world:AddLocation( hood )

	Location.Connect( start, hood )

	local player = Agent()
	player:SetFlags( Agent.FLAGS.PLAYER )
	player:SetDetails( "Han" )
	player:GainAspect( Aspect.Scrounge() )
	world:AddAgent( player )

	local other = Agent()
	other:SetDetails( "Kevin" )
	other:GainAspect( Aspect.Cowardly() )
	world:AddAgent( other )

	player:MoveToLocation( start )
	other:MoveToLocation( start )
end
