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


	local city = Zone.City( self, 3 )
	world:SpawnEntity( city )

	local forest = Zone.Forest( self, 4 )
	forest.origin = city:RandomBoundaryPortal().owner.location
	world:SpawnEntity( forest )


			
	--------------------------------------------------------------------------------------
	-- Place the player.

	local player = Agent.Grifter()
	world:SpawnAgent( player, city:RandomRoom() )

	--------------------------------------------------------------------------------------

	local zones = world:CreateBucketByClass( Zone )
	print( table.count( zones ), " total zones." )

	return self.world
end
