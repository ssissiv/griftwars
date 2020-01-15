-- 1.0 unit of datetime is meant to represent 1 hour,
-- so a WALL_TO_GAME_TIME of 1.0 means every real world second is equivalent to 1 game hour.
WALL_TO_GAME_TIME = 1/60.0 -- eg. 1 wall second == 1 game minute.

-- Note: 'datetime' is a floating point measure of game hours passed.
ONE_MINUTE = 1/60
HALF_HOUR = 30/60
ONE_HOUR = 1

HALF_DAY = ONE_HOUR * 12
ONE_DAY = ONE_HOUR * 24

ONE_WEEK = ONE_DAY * 7

-- 6 am.
DATETIME_START = 7

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

PAUSE_TYPE = MakeEnum{ "DEBUG", "CONSOLE", "FOCUS_MODE", "NEXUS" }

OPINION = MakeEnum
{
	"NEUTRAL",
	"FEAR",
	"LIKE",
	"DISLIKE",
}

GENDER = MakeEnum
{
	"MALE",
	"FEMALE",
	"NEUTRAL",
}

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

OPINION_STRINGS =
{
	[ OPINION.FEAR ] =
	{
		"{1.Id} fears you!",
		"You fear {1.id}!",
	},

	[ OPINION.LIKE ] =
	{
		"{1.Id} likes you a little more!",
		"You like {1.id} a little more!",
	}
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

EQ_SLOT = MakeEnum
{
	"HAND",
	"LHAND",
	"RHAND",
	"HEAD",
	"BODY",
	"FEET",
}

SENSOR = MakeEnum
{
	"ECHO", -- Meta sense. Game logging.
	"VISION", -- in-game vision
}
WORLD_EVENT = MakeEnum{
	"LOG",
	"START", -- Start() occurs after all entities have been spawned.
	"VERB_FINISH",	
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
}

LOCATION_EVENT = MakeEnum{
	"AGENT_ADDED",
	"AGENT_REMOVED",
}

SHOP_TYPE = MakeEnum{
	"GENERAL",
	"FOOD",
	"EQUIPMENT",
}

-- Verb priorities, which determine behaviour.
PRIORITY =
{
	-- Life & death situation, or something the Agent would prioritize over life & death.
	EMERGENCY = 100,
	-- Something an Agent really should be doing, like a job.
	OBLIGATION = 50,
	-- A habit that takes place when any Obligations are satisfied.
	HABIT = 30,
	-- Low priority verbs, only if nothing else is going on.
	FUN = 25,
}

STAT = MakeEnum
{	
	-- Core stats
	"FATIGUE",

	-- Trainable stats.
	"STATURE",
	"MIND",
	"CHARISMA",

	-- Dynamic stats
	"CRUELTY",
	"GRIT",
	"CRAFT",
	
	"XP",

	-- Transient stats
	"PATIENCE",
}

-- Challenge ratings
CR0 = 0
CR1 = 1
CR2 = 2
CR3 = 3
CR4 = 4
CR5 = 5


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


INFO = MakeEnum
{
	"NULL",
	
	"LOCAL_NEWS",
--	"GOSSIP",
--  'RUMOURS",
}
