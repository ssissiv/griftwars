return {
	CONSOLE = {
		docked = true,
		history = {
			"print(screen:ScreenToTile( 400, 0 ))",
			"print(screen:ScreenToTile( 400, 400 ))",
			"print(GetGUI():GetSize())",
			"print(screen:ScreenToTile( 400, 300 ))",
			"print(screen.camera.y)",
			"print(screen.camera.x)",
			"print(screen.camera.y)",
			"print(t:CountAvailableExits())",
			"print(world:GetLocationAt(-2,0))",
			"print(world:GetLocationAt(-4,0))",
			"print(world:GetLocationAt(-3,0))",
			"print(world:GetLocationAt(-3,-1))",
			"print(world:GetLocationAt(-3,1))",
			"print(tostring(world:GetLocationAt(-3,1)))",
			"print(t)",
			"print(t.available_exits[1])",
			"print(OffsetExit( t.x, t.y, t.available_exits[1]))",
			"print(OffsetExit( t.x, t.y, t.available_exits[2]))",
			"print(tostring(world:GetLocationAt(-3,1)))",
			"print(t:CountAvailableExits())",
			"wg = WorldGen(world); print(wg:CountSpaces(0, 0, 99 ))",
			"wg = WorldGen(world); print(wg:CountSpace(0, 0, 99 ))",
			"wg = WorldGen(world); print(wg:CountSpace(-1,-1, 99 ))",
			"wg = WorldGen(world); print(wg:CountSpace(1, 0, 99 ))",
			"wg = WorldGen(world); print(wg:CountSpace(6, 0, 99 ))",
			"wg = WorldGen(world); print(wg:CountSpace(5, -1, 99 ))",
			"wg = WorldGen(world); print(wg:CountSpace(2, -1, 10  ))",
			"rng = love.math.newRandomGenerator(); print( rng, rng:random(), rng:random( 10 ))",
			"rng = love.math.newRandomGenerator(); print( rng, rng:random(), rng:random( 10, 20 ))",
			"rng = love.math.newRandomGenerator(); print( rng, rng:random(), rng:random())",
			"print(t:FindStrategicPoint())",
			"print(t:FindStrategicPoint( t.owner ))"
		}
	},
	DEBUG_FILE = "debug.lua"
}