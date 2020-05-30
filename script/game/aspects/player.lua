---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Aspect.Player", Aspect )

function Player:CollectVerbs( verbs, actor, obj )
	if self.owner == actor and obj == actor then
		verbs:AddVerb( Verb.Wait())

		if self.owner:GetStat( STAT.FATIGUE ):GetThreshold() >= FATIGUE.TIRED then
			verbs:AddVerb( Verb.Sleep() )
		end
	end
end

