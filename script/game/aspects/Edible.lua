local Edible = class( "Aspect.Edible", Aspect )

function Edible:CollectVerbs( verbs, actor, obj )
	if obj == self.owner and actor:CanReach( obj ) then
		verbs:AddVerb( Verb.Eat( nil, self.owner ))
	end
end

