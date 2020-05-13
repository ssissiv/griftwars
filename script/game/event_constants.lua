WORLD_EVENT = MakeEnum{
	"LOG",
	"START", -- Start() occurs after all entities have been spawned.
	"INTERRUPT", -- Interrupt for AdvanceTime.
	"VERB_FINISH",
	"PUPPET_CHANGED",
	"PAUSED", -- Pause status changed
}

ENTITY_EVENT = MakeEnum{
	"ASPECT_GAINED",
	"ASPECT_LOST",
}

AGENT_EVENT = MakeEnum{
	"VERB_UNASSIGNED",
	"FOCUS_CHANGED",
	"COLLECT_VERBS",
	"LOCATION_CHANGED",
	"TILE_CHANGED",
	"KILLED",
}

LOCATION_EVENT = MakeEnum{
	"AGENT_ADDED",
	"AGENT_REMOVED",
	"ENTITY_EVENT",
}

