
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

function Scrounge:CanInteract( actor, obj )
	if obj ~= nil then
		return false
	end

	return true
end

function Scrounge:GetDesc()
	return "Scrounge"
end

function Scrounge:Interact( actor )
	Msg:Action( self.STRINGS, actor )
end
