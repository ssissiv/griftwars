return {
	CONSOLE = {
		docked = true,
		history = {
			"print(t:GetAspect(Aspect.Cowardly))",
			"print(t:GetAspect(Trait.Cowardly))",
			"print(t:GetAspect(Trait.Cowardly)._classname)",
			"print(t)",
			"print(player)",
			"print(puppet)",
			"print(agent)",
			"help()",
			"print(player)",
			"print(player:GetFocus())",
			"print(player)",
			"print(player.potential_verbs)",
			"print(tostr(player.potential_verbs))",
			"Verb:RecurseSubclasses( nil, function(...) print( ... ) end )",
			"Verb:RecurseSubclasses( nil, function(c) print( c._classname ) end )",
			"player:CollectInteractions()",
			"print(world:IsPaused())",
			"print(tostr(world.pause))",
			"t:Regen()",
			"t.value = 0",
			"print( CheckBits( 2, 0 ))",
			"print( CheckBits( 2, 2 ))",
			"print( CheckBits( 3, 2 ))",
			"print( CheckBits( 3, 5 ))",
			"print( CheckBits( 3, 8 ))",
			"print( SetBits( 0, 2 ))",
			"print(actor)",
			"print(actor:CheckPrivacy( obj, PRIVACY.ID ))",
			"print(actor:CheckPrivacy( obj, PRIVACY.LOOKS ))",
			"print( player.verbs[1] )",
			"print( player.verbs[1]:CanInteract())",
			"l"
		}
	},
	DEBUG_FILE = "debug.lua"
}