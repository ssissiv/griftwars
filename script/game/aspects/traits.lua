---------------------------------------------------------------

local Cowardly = class( "Aspect.Cowardly", Aspect )
Cowardly.STRINGS =
{
	"You push {2.name} around and enjoy it.",
	"{1.name} pushes you around roughly. Jerk.",
	"{1.name} pushes {2.name} around.",
}

function Cowardly:CanInteract( actor, obj )
	if actor ~= self.agent and obj == self.agent then
		return true, "Intimidate"
	end
	return false
end

function Cowardly:Interact( actor, obj )
	obj.intimidated = true
	
	Msg:Action( self.STRINGS, actor, obj )
end

---------------------------------------------------------------
