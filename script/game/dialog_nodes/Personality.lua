local FIRST_CONTACT =
{
	name = "First Contact",
}

local CHAT =
{
	name = "Chat",
}

local BASIC_EDGE =
{
	stat_reqs = {
		{ stat_id = STAT.CHARISMA, min_value = 5 },
	}
}

-----------------------------------------------

local Personality = class( "Personality" )

function Personality.MakeSimpleton( agent )
	local root = DialogNode.FirstContact( agent )
	return root
end

