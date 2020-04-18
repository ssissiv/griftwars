---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Aspect.Player", Aspect )

function Player:init()
end

function Player:CollectVerbs( verbs, actor )
	verbs:AddVerb( Verb.Wait( actor ))
end

