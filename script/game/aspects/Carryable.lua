local Carryable = class( "Aspect.Carryable", Aspect )

function Carryable:CollectVerbs( verbs, actor, obj )
	if obj == self.owner and obj:GetCarrier() == nil then
		verbs:AddVerb( Verb.LootObject( nil, self.owner ))
	end
end

