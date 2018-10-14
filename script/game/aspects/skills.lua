---------------------------------------------------------------

local Scrounge = class( "Aspect.Scrounge", Aspect )
Scrounge.STRINGS =
{
	"You scrounge a bit, looking for useful things.",
	nil,
	"{1.name} rummages around, looking for something.",
}

function Scrounge:CanInteract( actor, obj )
	if actor == self.agent and obj == nil then
		return true, "Scrounge around the area to look for something useful"
	end
	return false
end

function Scrounge:Interact( actor )
	Msg:Action( self.STRINGS, actor )
end

---------------------------------------------------------------
