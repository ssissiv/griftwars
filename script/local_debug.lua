return {
	CONSOLE = {
		docked = true,
		history = {
			"print(a:CheckPrivacy( t, PRIVACY.ID ))",
			"print( now )",
			"print(t:CanAct())",
			"print(t:CanInteract( t.actor ))",
			"puppet:GainAspect( Skill.Scrounge() )",
			"player:GainAspect( Skill.Scrounge() )",
			"puppet:GainAspect( Skill.Scrounge() )",
			"print( table.unpack( { 1, nil, 3 } ))",
			"print( table.maxn( { 1, nil, 3 } ))",
			"print( table.unpack( { 1, nil, 3 }, 3 ))",
			"print(t)",
			"print(t:GetLocation(), t:GetHome())",
			"print(player:GetAspect( t ))",
			"print(player:GetAspect( \"foo\" ))",
			"print(player:GetAspect( t ))",
			"print(player:GetAspect( t ), t)",
			"DBG(CLASSES)",
			"puppet:GetInventory():AddItem( Weapon.Dirk() )",
			"print( is_class( t ))",
			"print( t._class )",
			"print( Feature.Home )",
			"print( Feature.Home._class )",
			"print( t._class )",
			"print( t._class._class )",
			"print( Feature.Home )",
			"print(tostr(Feature.Home))",
			"print( tostr(t._class))",
			"print(t._class, Feature.Home)",
			"print( #world.agents)",
			"print(t:GetLocation())",
			"print(world.adjectives:PickName())",
			"DBG(world.adjectives)"
		}
	},
	DEBUG_FILE = "debug.lua"
}