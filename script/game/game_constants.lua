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
}
