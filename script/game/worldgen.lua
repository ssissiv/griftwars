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

	local player = Agent()
	player:SetFlags( Agent.FLAGS.PLAYER )
	player:SetDetails( "Han" )
	world:AddAgent( player )

	world:MoveAgent( player, start )
end
