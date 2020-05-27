local Eat = class( "Verb.Eat", Verb )

function Eat:GetDesc()
	return loc.format( "Eat {1}", tostring(self.obj) )
end

function Eat:CanInteract( actor, obj )
	local edible = obj:GetAspect( Aspect.Edible )
	if not edible then
		return false, "Not edible"
	end
	return true
end

function Eat:Interact( actor, obj )	
	local edible = obj:GetAspect( Aspect.Edible )
	Msg:Echo( actor, "You eat {1}.", obj )
	actor.world:DespawnEntity( obj )
end
