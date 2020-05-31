
local Befriend = class( "Verb.Befriend", Verb )

Befriend.can_repeat = true -- This interaction can take place multiple times.

function Befriend:GetRoomDesc( viewer )
	return loc.format( "Befriend {1.Id}", self.obj and self.obj:LocTable( viewer ))
end

function Befriend:CalculateUtility()
	return UTILITY.FUN
end

function Befriend:CanInteract( actor, target )
	if not target:IsAlert() then
		return false, "Not alert"
	end
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

	-- self:AttachActor( target )

	self:YieldForTime( HALF_HOUR, "wall", 1.0 )

	if self:IsCancelled() then
		Msg:Echo( actor, "So much for making friends." )
		return
	end

	local trust = math.random( 0, actor:GetStatValue( CORE_STAT.CHARISMA ))

	if trust > 0 then
		Msg:Echo( actor, "You befriend {1.Id}.", target:LocTable( actor ))
		target:DeltaTrust( trust )
		actor:GainXP( trust )
	end
end

