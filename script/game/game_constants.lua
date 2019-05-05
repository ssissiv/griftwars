-- 1 second == 1 game minute.
WALL_TO_GAME_TIME = 1/60.0

PAUSE_TYPE = MakeEnum{ "DEBUG", "CONSOLE", "GAME" }

-- Note: 'datetime' is a floating point measure of game hours passed.
ONE_MINUTE = 1/60
HALF_HOUR = 30/60
ONE_HOUR = 1

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
		"{1.name} fears you!",
		"You fear {1.name}!",
	},

	[ OPINION.LIKE ] =
	{
		"{1.name} likes you a little more!",
		"You like {1.name} a little more!",
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
	"VERB_FINISH",	
}

STAT = MakeEnum
{
	-- Core stats
	"STATURE",
	"MENTALITY",
	"CHARISMA",

	-- Dynamic stats
	"CRUELTY",
	"GRIT",
	"CRAFT",

	-- Transient stats
	"PATIENCE",
}

INFO = MakeEnum
{
	"NULL",
	
	"LOCAL_NEWS",
--	"GOSSIP",
--  'RUMOURS",
}
