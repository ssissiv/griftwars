-- 1 second == 1 game minute.
WALL_TO_GAME_TIME = 1/60.0

PAUSE_TYPE = MakeEnum{ "DEBUG", "CONSOLE", "FOCUS_MODE", "NEXUS" }

CHARACTER_NAMES = LoadLinesFromFile( "data/names.txt" )

-- Note: 'datetime' is a floating point measure of game hours passed.
ONE_MINUTE = 1/60
HALF_HOUR = 30/60
ONE_HOUR = 1

HALF_DAY = ONE_HOUR * 12
ONE_DAY = ONE_HOUR * 24

ONE_WEEK = ONE_DAY * 7

SLEEP_SPEED_RATE = 16.0

-- 6 am.
DATETIME_START = 7

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

WORLD_EVENT = MakeEnum{
	"LOG",
	"START", -- Start() occurs after all entities have been spawned.
	"VERB_FINISH",	
}

AGENT_EVENT = MakeEnum{
	"VERB_UNASSIGNED",
	"FOCUS_CHANGED",
	"COLLECT_VERBS",
	"CALC_AGENDA",
	"LOCATION_CHANGED",
}

LOCATION_EVENT = MakeEnum{
	"AGENT_ADDED",
	"AGENT_REMOVED",
}

STAT = MakeEnum
{
	-- Core stats
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
	"FACE_COUNT"
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
