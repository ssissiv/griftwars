
local Befriend = class( "Verb.Befriend", Verb )

Befriend.can_repeat = true -- This interaction can take place multiple times.

function Befriend:GetRoomDesc( viewer )
	return loc.format( "Befriend {1.Id}", self.obj and self.obj:LocTable( viewer ))
end

function Befriend:CanInteract( actor, target )
	local affinity = target:GetAffinity( actor )
	if affinity == AFFINITY.FRIEND then
		return false
	end
	if affinity == AFFINITY.UNFRIEND or affinity == AFFINITY.ENEMY then
		return false, "Doesn't like you"
	end
	if actor:GetMaxFriends() <= actor:CountAffinities( AFFINITY.FRIEND ) then
		return false, "Max friends reached"
	end

	return Verb.CanInteract( actor, target )
end

function Befriend:CollectVerbs( verbs, actor, obj )
	if actor == self.owner and obj ~= actor and is_instance( obj, Agent ) then
		self.obj = obj
		verbs:AddVerb( self )
	end
end

function Befriend:Interact( actor, target )

	local trust = math.random( 0, actor:GetStatValue( CORE_STAT.CHARISMA ))

	if trust > 0 then
		Msg:Echo( actor, "You befriend {1.Id}.", target:LocTable( actor ))
		target:DeltaTrust( trust )
	end
end

