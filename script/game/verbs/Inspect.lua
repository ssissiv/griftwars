local Inspect = class( "Verb.Inspect", Verb )

function Inspect:CollectVerbs( verbs, actor, obj )
	if obj and actor:GetFocus() == obj then
		verbs:AddVerb( Verb.Inspect( actor, obj ))
	end
end

function Inspect:GetDesc()
	return "Inspect"
end

function Inspect:Interact( actor )
	local obj = actor:GetFocus()
	actor.world.nexus:Inspect( actor, obj )
end

