---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Aspect.Player", Aspect )

function Player:init()
end

function Player:CollectVerbs( verbs, actor, obj )
	if obj == actor then
		verbs:AddVerb( Verb.Wait())
	end
end

