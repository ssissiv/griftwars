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
	local root = DialogNode( FIRST_CONTACT, agent )
	local chat = DialogNode( CHAT, agent )

	local edge = DialogEdge( BASIC_EDGE, agent )
	root:AddDirectionalEdge( chat, edge )


	return root
end

