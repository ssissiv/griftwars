return {
	CONSOLE = {
		docked = true,
		history = {
			"s = \"district\"; print(tostr(s:split( \" \" )))",
			"s = \"district west\"; print(tostr(s:split( \" \" )))",
			"s = \"distric  t west\"; print(tostr(s:split( \" \" )))",
			"s = \"district  west\"; print(tostr(s:split( \" \" )))",
			"s = \"district two west\"; print(tostr(s:split( \" \" )))",
			"s = \"distric t two west\"; print(tostr(s:split( \" \" )))",
			"s = \"distric t two  west\"; print(tostr(s:split( \" \" )))",
			"s = \"distric td two  west\"; print(tostr(s:split( \" \" )))",
			"print(location.world)",
			"print(screen.hovered_tile)",
			"print(screen)",
			"print(screen.hovered_tile)",
			"sdf",
			"print(now)",
			"print(Calendar.FormatTime(now))",
			"print(agent)",
			"print(agent, agent:IsDead())",
			"print(agent:GetCoordinate())",
			"print(agent, agent:GetCoordinate())",
			"print( player, player:GetCoordinate())",
			"print( distance( 11, 1, 10,2 ))",
			"print(t:GetAspect( Aspect.Combat ):GetCurrentAttack() )",
			"print(world.datetime",
			"print(world.datetime)",
			"print(now)",
			"print(t, agent, t:IsPassable( agent ))",
			"print(agent)",
			"print(t, agent, t:IsPassable( agent ))",
			"print(screen.current_focus)",
			"print( os.time())",
			"print( os.date())",
			"DBG(debug.getinfo(2))"
		}
	},
	DEBUG_FILE = "debug.lua"
}