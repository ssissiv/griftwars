---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Aspect.Player", Aspect )

function Player:CollectVerbs( verbs, actor, obj )
	if self.owner == actor and obj == actor then
		verbs:AddVerb( Verb.Wait())

		if self.owner:GetStat( STAT.FATIGUE ):GetThreshold() >= FATIGUE.TIRED then
			verbs:AddVerb( Verb.Sleep() )
		end

	elseif is_instance( obj, Agent ) then
		verbs:AddVerb( Verb.Follow( obj, 4 ))
	end
end

function Player:OnLocationChanged( prev, location )
	if location then
		location:Discover( self.owner )
	end
end
