return {
	CONSOLE = {
		docked = true,
		history = {
			"print(t)",
			"DBG(t:FindStrategicPoint())",
			"print(t)",
			"v = t",
			"print(t)",
			"DBG(v:FindStrategicPoint(t))",
			"DBG(t:FindStrategicPoint())",
			"print( t.RenderAgentDetails )",
			"print(puppet:IsEnemy(t))",
			"print(t:IsEnemy(puppet))",
			"print(t:EvaluateTarget( puppet ))",
			"DBG(world.factions)",
			"t:GetAspect( Aspect.Combat ):EvaluateTarets()",
			"t:GetAspect( Aspect.Combat ):EvaluateTargets()",
			"print(t:IsDoing())",
			"print(t.owner)",
			"print(t.owner:IsBusy(VERB_FLAGS.MOVEMENT))",
			"print(t:CanInteract())",
			"print(t:CanInteract(t.actor))",
			"print( location.map )",
			"print(puppet.location)",
			"print(puppet.location.map)",
			"print(puppet.location.map:LookupGrid( 2, 2 ))",
			"DBG(location.map)",
			"print(puppet.location.map:LookupGrid( 2, 2 ))",
			"print( is_instance( {} ))",
			"print( is_instance( Entity() ))",
			"print(puppet.location.map:LookupGrid( 2, 2 ))",
			"DBG(location.map)",
			"print(t.image)",
			"DBG( location.map)",
			"print(32*32)"
		}
	},
	DEBUG_FILE = "debug.lua"
}