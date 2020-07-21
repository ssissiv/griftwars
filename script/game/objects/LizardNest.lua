require "game/objects/SpawnPoint"

local LizardNest = class( "Object.LizardNest", Object.SpawnPoint )

LizardNest.tick_duration = ONE_HOUR
LizardNest.spawn_class = Agent.GiantLizard
LizardNest.spawn_max = 3
