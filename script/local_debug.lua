return {
	CONSOLE = {
		docked = true,
		history = {
			"print( t:GetAspect( Aspect.Combat ):EvaluateTarget( player ))",
			"print( player:GetAspect( Aspect.Combat ))",
			"print(t)",
			"print(t:IsEnemy( player ))",
			"print(player.combat)",
			"print(player.faction)",
			"print(t.faction)",
			"print(t:GetBounds())",
			"for i, v in ipairs( t.rooms ) do print( i, v:GetCoordinate() ) end",
			"print(location:GetCoordinate())",
			"print(t:GetBounds())",
			"puppet:CollectPotentialVerbs()",
			"puppet:CollectPotentialVerbs( \"tile\" )",
			"puppet:RegenVerbs( \"tile\" ); puppet:CollectPotentialVerbs( \"tile\" )",
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
			"print(screen.current_verb)"
		}
	},
	DEBUG_FILE = "debug.lua"
}