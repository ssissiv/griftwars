
local Scrounge = class( "Verb.Scrounge", Verb )
Scrounge.STRINGS =
{
	"You scrounge a bit, looking for useful things.",
	nil,
	"{1.name} rummages around, looking for something.",
}

function Scrounge:GetDesc()
	return "Scrounge around the area to look for something useful"
end

function Scrounge:Interact( actor )
	Msg:Action( self.STRINGS, actor )
end
