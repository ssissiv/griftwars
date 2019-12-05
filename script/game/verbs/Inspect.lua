local Inspect = class( "Verb.Inspect", Verb )

function Inspect.CollectInteractions( actor, verbs )
	if actor:GetFocus() then
		verbs:AddVerb( Verb.Inspect( actor, actor:GetFocus() ))
	end
end

function Inspect:GetDesc()
	return "Inspect"
end

function Inspect:Interact( actor )
	local obj = actor:GetFocus()
	actor.world.nexus:ShowAgentDetails( actor, obj )
end

