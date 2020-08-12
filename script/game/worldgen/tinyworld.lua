local TinyWorld = class( "WorldGen.TinyWorld", WorldGen )

function TinyWorld:GenerateWorld()
	local world = World( self )
	self.world = world

	Msg:SetWorld( world )

	local origin = Location.JunkYard()
	origin:SetDetails( "Tiny World", "Not much here." )
	origin:SetCoordinate( 0, 0 )
	world:SpawnLocation( origin )

	for i = 1, 1 do
		local npc = Agent.HillGiant()
		npc:WarpToLocation( origin, 8, 13 )
	end
	for i = 1, 4 do
		Object.Boulder():WarpToLocation( origin, math.random( 10 ), math.random( 10 ))
	end
	
	local player = Agent.Grifter()
	player:SetFlags( Agent.FLAGS.PLAYER )
	world:SpawnAgent( player, origin )
	world:SetPuppet( player )

	return world

end