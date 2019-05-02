
local Scrounge = class( "Verb.Scrounge", Verb )

Scrounge.ACT_DESC =
{
	"You are scrounging for some useful things.",
	nil,
	"{1.name} is here rummaging around.",
}

Scrounge.STRINGS =
{
	"You scrounge a bit, looking for useful things.",
	nil,
	"{1.name} rummages around, looking for something.",
}
Scrounge.VERB_DURATION = ONE_HOUR


function Scrounge.CollectInteractions( actor, verbs )
	if actor.location then
		table.insert( verbs, Verb.Scrounge( actor ))
	end
end

function Scrounge:CalculateDC( mods )
	return 10
end

function Scrounge:GetDesc()
	return "Scrounge"
end

function Scrounge:Interact( actor )
	Msg:Action( self.STRINGS, actor )
	if self:CheckDC() then
		local coins = math.random( 1, 3 )
		Msg:Echo( actor, "You find {1#money}!", coins )
		actor:GetInventory():DeltaMoney( coins )
	else
		Msg:Echo( actor, "You don't find anything useful." )
	end
end
