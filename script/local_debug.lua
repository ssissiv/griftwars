return {
	CONSOLE = {
		docked = true,
		history = {
			"puppet:RegenVerbs(\"room\" ); DBG(puppet)",
			"print(tostr(puppet:GetPotentialVerbs(\"room\" ))",
			")",
			"print(tostr(puppet:GetPotentialVerbs(\"room\" )))",
			"print(tostr(puppet:GetPotentialVerbs(\"room\" ),2))",
			"puppet:SetFocus(t)",
			"puppet:CollectPotentialVerbs(\"room\")",
			"print(screen.puppet)",
			"print(location)",
			"print(tostr(location.exits))",
			"print(tostr(location.portals))",
			"print(t:GetTarget())",
			"print(screen.current_verb)",
			"print(player.location)",
			"DBG(screen.current_verb)",
			"print(tostr(screen.current_verb))",
			"screen:PanToCurrentInterest()",
			"print(screen.current_verb)",
			"print(t)",
			"print(t:IsAdjacent( player ))",
			"print(t:GetCoordinate())",
			"print(t:IsAdjacent( player ))",
			"print(t:GetCoordinate())",
			"print(t:IsAdjacent( player ))",
			"print(player)",
			"print(player:GetCoordinate())",
			"DBG(screen.windows[1])",
			"print(debug.traceback(t.coro))",
			"print(puppet)",
			"print(puppet.location)",
			"print(puppet.location.map)",
			"print(tostr(world.pause))"
		}
	},
	DEBUG_FILE = "debug.lua"
}