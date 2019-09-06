return {
	CONSOLE = {
		docked = true,
		history = {
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
			"l",
			"DBG(player)",
			"print( loc.format( \"{1#listing}\", { \"what\", \"foo\" } ))",
			"print( loc.format( \"{1#listing}\", { DIE_FACE.DIPLOMACY } ))",
			"print(world:GetDateTime())",
			"print( Calendar.FormatWallTime( 60 ))",
			"print( Calendar.FormatWallTime( 1 ))",
			"print( Calendar.FormatWallTime( 1 / 60 ))",
			"print( Calendar.FormatWallTime( 10 ))",
			"print( Calendar.FormatWallTime( 24 ))",
			"print( Calendar.FormatWallTime( 59 ))",
			"print( Calendar.FormatWallTime( 60 ))",
			"print( Calendar.FormatWallTime( 61 ))",
			"print( Calendar.FormatWallTime( 161 ))"
		}
	},
	DEBUG_FILE = "debug.lua"
}