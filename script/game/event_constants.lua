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
	"TILE_CHANGED",

	"COMBAT_STARTED",
	"COMBAT_ENDED",
}

AGENT_EVENT = MakeEnum{
	"VERB_UNASSIGNED",
	"FOCUS_CHANGED",
	"COLLECT_VERBS",
	"LOCATION_CHANGED",
	"INTENT_CHANGED",
	"ACTIVATED_PORTAL",
	"DIED",
	"KILLED",

	-- Attacker events.
	"PRE_ATTACK",
	"POST_ATTACK",

	-- Victim events.
	"ATTACKED",
}

CALC_EVENT = MakeEnum{
	"ATTACK_POWER",
	"DAMAGE",
	"STAT",
	"DC",
	"COLLECT_INTEL",
	"IS_ALLY",
}

LOCATION_EVENT = MakeEnum{
	"AGENT_ADDED",
	"AGENT_REMOVED",
	"ATTACK",
	"ENTITY_EVENT",
}

