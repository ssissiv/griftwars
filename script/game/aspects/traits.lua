---------------------------------------------------------------
local MSGS =
{
	"You push {2.name} around and enjoy it.",
	"{1.name} pushes you around roughly. Jerk.",
	"{1.name} pushes {2.name} around.",
}

local Cowardly = class( "Aspect.Cowardly", Aspect )

function Cowardly:CanInteract( actor, obj )
	if obj == self.agent and is_instance( obj, Agent ) then
		return true, "Intimidate"
	end
	return false
end

function Cowardly:Interact( actor, obj )
	obj.intimidated = true
	
	Msg:Action( MSGS, actor, obj )
end

---------------------------------------------------------------
