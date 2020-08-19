require "game/event_constants"
require "game/input_constants"
require "game/combat_constants"

-- 1.0 unit of datetime is meant to represent 1 hour,
-- so a WALL_TO_GAME_TIME of 1.0 means every real world second is equivalent to 1 game hour.
WALL_TO_GAME_TIME = 1/60.0 -- eg. 1 wall second == 1 game minute / 1 wall minute = 1 game hour

-- Note: 'datetime' is a floating point measure of game hours passed.
ONE_SECOND = 1/3600
ONE_MINUTE = 1/60
HALF_HOUR = 30/60
ONE_HOUR = 1

HALF_DAY = ONE_HOUR * 12
ONE_DAY = ONE_HOUR * 24

ONE_WEEK = ONE_DAY * 7

-- 6 am.
DATETIME_START = 13

TILE_SIZE = 64

-- Default camera zoom
DEFAULT_ZOOM = 1 / TILE_SIZE

-- Standard action durations
WALK_TIME = ONE_SECOND * 10
RUN_TIME = ONE_SECOND * 4
ATTACK_TIME = ONE_SECOND * 3
TRAVEL_TIME = WALK_TIME -- ONE_MINUTE * 10

-- World speed multipliers.
DEBUG_WORLD_SPEEDS =
{
	1/60, -- eg. 1 wall second == 1 game second
	0.5, -- eg. 1 wall second == half a game minute
	1.0,
	5.0, -- eg. 1 wall second == 5 game minutes
	60.0, -- eg. 1 wall second == 1 game hour
	360.0, -- eg. 1 wall second == 6 game hours
}

DEFAULT_DEBUG_SPEED = table.find( DEBUG_WORLD_SPEEDS, 1.0 )
assert( DEFAULT_DEBUG_SPEED )

PAUSE_TYPE = MakeEnum{ "DEBUG", "ERROR", "CONSOLE", "FOCUS_MODE", "NEXUS", "GAME_OVER", "IDLE", "INTERRUPT" }

GENDER = MakeEnum
{
	"MALE",
	"FEMALE",
	"NEUTRAL",
}
GENDER_ARRAY = { GENDER.MALE, GENDER.FEMALE, GENDER.NEUTRAL }

MSTATE = MakeEnum
{
	"ALERT",
	"STUNNED",
	"SLEEPING",
	"KO",
	"DEAD",
}

GENERATION, GENERATION_ARRAY = MakeEnum
{
	"BABY",
	"CHILD",
	"YOUTH",
	"ADULT",
	"ELDER",
}

INTENT, INTENT_ARRAY = MakeBitField
{
	"HOSTILE",
	"STEALTH",
	"DIPLOMACY",
}

INTENT_NAME =
{
	HOSTILE = "[H]ostile",
	STEALTH = "Stea[l]th",
	DIPLOMACY = "[D]iplomacy",
}

-- Agent flags
EF = MakeEnum
{
	"AGGRO_NONE", -- Aggro to nobody
	"AGGRO_ALL", -- Aggro to everybody
	"AGGRO_OTHER_CLASS", -- Aggro to other class instances
	"AGGRO_OTHER_FACTION", -- Aggro to other factions
}

TAG = MakeEnum
{
	"USED", -- Used by worldgen.
}

PRIVACY = MakeBitField
{
	"ID", -- Name, status, basic stats.
	"LOOKS", -- What they look like.
	"HAUNTS", -- Where they hang out.
	"STATS", -- Detailed status.
	"INTENT", -- Goals, AI status.
}
PRIVACY_ALL = 0xFFFFFFFF

AFFINITY = MakeEnum
{
	"STRANGER", -- Stranger, identiy not known.
	"KNOWN", -- Neutral relationship, but identity known.
	"FRIEND", -- Friend.
	"UNFRIEND", -- Former friend.
	"ENEMY", -- Enemy!
}

SPECIES = MakeEnum{ "NONE", "HUMAN", "ORC", "GIANT", "MAMMAL", "GNOLL" }
SPECIES_ARRAY = MakeArrayFromEnum( SPECIES )

table.arrayremove( SPECIES_ARRAY, SPECIES.NONE )

SPECIES_PROPS =
{
	NONE =
	{
		name = "NO-SPECIES",
		can_speak = true,
	},
	HUMAN = 
	{
		name = "human",
		sentient = true,
		name_pool = true,
		can_speak = true,
	},
	ORC =
	{
		name = "orc",
		can_speak = true,
	},
	GNOLL =
	{
		name = "gnoll",
	},
	GIANT =
	{
		name = "giant",
		can_speak = true,
	},
	MAMMAL =
	{
		name = "mammal",
		can_speak = false,
	},
}
for i, species in ipairs( SPECIES_ARRAY ) do
	assert( SPECIES_PROPS[ species ] ~= nil or error( "Missing props for: " ..tostring(species) ))
end

EQ_SLOT = MakeEnum
{
	"WEAPON",
	"HELD",
	-- "HAND",
	-- "LHAND",
	-- "RHAND",
	"HEAD",
	"BODY",
	"FEET",
	"RING",
}
EQ_SLOT_ARRAY = MakeArrayFromEnum( EQ_SLOT )


EQ_SLOT_NAMES =
{
	[EQ_SLOT.WEAPON] = "main weapon",
	[EQ_SLOT.HELD] = "held",
	-- [EQ_SLOT.LHAND] = "left hands",
	-- [EQ_SLOT.RHAND] = "right hand",
	[EQ_SLOT.HEAD] = "head",
	[EQ_SLOT.BODY] = "body",
	[EQ_SLOT.FEET] = "feet",
	[EQ_SLOT.RING] = "ring",
}

QUALITY =
{
	JUNK = 0,
	POOR = 1,
	AVERAGE = 2,
	GOOD = 3,
}

QUALITY_STRINGS = {}
for k, v in pairs( QUALITY ) do
	QUALITY_STRINGS[ v ] = tostring(k)
end


SENSOR = MakeEnum
{
	"ECHO", -- Meta sense. Game logging.
	"VISION", -- in-game vision
}

DIR = MakeEnum{ "N", "NE", "E", "SE", "S", "SW", "W", "NW" }

ADJACENT_DIR =
{
    [DIR.N] = { DIR.NE, DIR.NW },
    [DIR.NE] = { DIR.N, DIR.E },
    [DIR.E] = { DIR.NE, DIR.SE },
    [DIR.SE] = { DIR.E, DIR.S },
    [DIR.S] = { DIR.SE, DIR.SW },
    [DIR.SW] = { DIR.S, DIR.W },
    [DIR.W] = { DIR.NW, DIR.SW },
    [DIR.NW] = { DIR.N, DIR.W },
}

EXIT = MakeEnum{ "NORTH", "EAST", "WEST", "SOUTH" }
REXIT = {
	NORTH = EXIT.SOUTH,
	SOUTH = EXIT.NORTH,
	WEST = EXIT.EAST,
	EAST = EXIT.WEST,
}

EXIT_ARRAY = MakeArrayFromEnum( EXIT )

EXIT_TAG =
{
	[ EXIT.NORTH ] = "north",
	[ EXIT.SOUTH ] = "south",
	[ EXIT.EAST ] = "east",
	[ EXIT.WEST ] = "west",
}

SHOP_TYPE = MakeEnum{
	"GENERAL",
	"FOOD",
	"EQUIPMENT",
}
SHOP_TYPE_ARRAY = MakeArrayFromEnum( SHOP_TYPE )


-- Verb priorities, which determine behaviour.
UTILITY =
{
	MAX = 100,
	-- Life & death situation, or something the Agent would prioritize over life & death.
	EMERGENCY = 100,
	-- Comat priorites basically trump everything except EMERGENCY.
	COMBAT = 80,
	-- A higher promise the Agent is bound to, above their duty. eg. Joining the player.
	OATH = 60,
	-- Something an Agent really should be doing normally, like a job.
	DUTY = 50,
	-- A habit that takes place when any Obligations are satisfied.
	HABIT = 30,
	-- Low priority verbs, only if nothing else is going on.
	FUN = 25,
}

----------------------------------------------------------------------------------------------
-- Stat constants

CORE_STAT = MakeEnum
{
	"CHARISMA", "STRENGTH"
}

STAT = MakeEnum
{	
	-- Core stats
	"FATIGUE",
	"HEALTH",
	"XP",

	-- Transient stats
	"PATIENCE",
}

SKILL = MakeEnum
{
	"CLIMBING",
	"FIGHTING",
}

EFATIGUE, FATIGUE = MakeEnum{ "FRESH", "TIRED", "EXHAUSTED" }
FATIGUE_STRINGS =
{
	[FATIGUE.FRESH] = "Fresh",
	[FATIGUE.TIRED] = "Tired",
	[FATIGUE.EXHAUSTED] = "Exhausted",
}
FATIGUE_THRESHOLDS =
{
	{ value = 0, id = FATIGUE.FRESH, name = FATIGUE_STRINGS[ FATIGUE.FRESH ] },
	{ value = 75, id = FATIGUE.TIRED, name = FATIGUE_STRINGS[ FATIGUE.TIRED ] },
	{ value = 90, id = FATIGUE.EXHAUSTED, name = FATIGUE_STRINGS[ FATIGUE.EXHAUSTED ] },
}


-- Region numbers.
RGN_SERVING_AREA = 1 -- Bar serving areas

-- Challenge ratings
CR0 = 0
CR1 = 1
CR2 = 2
CR3 = 3
CR4 = 4
CR5 = 5

WAYPOINT = MakeEnum
{
	"KEEPER",
}

MATCH_TAGS =
{
	west = "east",
	east = "west",
	north = "south",
	south = "north",
	entry = "exit",
	exit = "entry"
}

DIE_FACE = MakeEnum
{
	"NULL",
	"DIPLOMACY",
	"HOSTILITY",
	"POWER",
	"STEALTH",

	-- Districts
	"DISTRICT_MIDGARD",
}

PIP_COUNT =
{
	DIPLOMACY = 1,
	DIPLOMACY_2X = 2,
	HOSTILITY = 1,
	HOSTILITY_2X = 2,
}

DLG_REQ = MakeEnum
{
	"NULL",
	"FACE_COUNT",
}

VERB_FLAGS = MakeBitField
{
	"MOVEMENT",
	"ATTENTION",
	"HANDS",
}

TOKEN = MakeEnum
{
	"DIPLOMACY_1",
	"DIPLOMACY_2",
	"DIPLOMACY_5",

	"POWER_1",
	"POWER_2",
	"POWER_5",

	"STEALTH_1",
}

TOKEN_TO_FACE =
{
	[ DIE_FACE.DIPLOMACY ] =
	{
		[ TOKEN.DIPLOMACY_1 ] = 1,
		[ TOKEN.DIPLOMACY_2 ] = 2,
		[ TOKEN.DIPLOMACY_5 ] = 5,
	},

	[ DIE_FACE.HOSTILITY ] =
	{

	},
}

FACTION_TAG = MakeEnum{ "ENEMY", "ALLY" }

FACTION_ROLE = MakeEnum{
	"COMMANDER",
	"CAPTAIN",
	"GUARD",
}

FACTION_TIERS =
{
	[ FACTION_ROLE.COMMANDER ] = 3,
	[ FACTION_ROLE.CAPTAIN ] = 2,
	[ FACTION_ROLE.GUARD ] = 1,
}

IMPASS = MakeBitField
{
	"STATIC", -- Static obstruction
	"DYNAMIC", -- Dynamic obstruction (agent, etc.)
	"OBJECT", -- Objects.
	"LOS", -- Blocks LOS
}

-- STATIC, DYNAMIC, PATHFIND
-- To query actual movement: 

INFO = MakeEnum
{
	"NULL",
	
	"LOCAL_NEWS",
--	"GOSSIP",
--  'RUMOURS",
}
