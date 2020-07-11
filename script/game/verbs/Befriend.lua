
local Befriend = class( "Verb.Befriend", Verb )

Befriend.INTENT_FLAGS = INTENT.DIPLOMACY
Befriend.can_repeat = true -- This interaction can take place multiple times.
Befriend.DC = 10

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
	if actor:InCombat() then
		return false, "In combat"
	end

	return Verb.CanInteract( self, actor, target )
end

function Befriend:CollectVerbs( verbs, actor, obj )
	if actor == self.owner and obj ~= actor and is_instance( obj, Agent ) and not obj:IsDead() then
		self.obj = obj
		verbs:AddVerb( self )
	end
end

function Befriend:Interact( actor, target )

	-- self:AttachActor( target )

	-- self:YieldForTime( 10 * ONE_MINUTE, "wall", 1.0 )

	if self:IsCancelled() then
		Msg:Echo( actor, "So much for making friends." )
		return
	end

	-- Check to generate
	local ok, result_str = self:CheckDC( actor, target )
	if ok then
		local trust = math.max( 1, math.random( 0, actor:GetStatValue( CORE_STAT.CHARISMA )))

		Msg:Echo( actor, "You befriend {1.Id}. ({2})", target:LocTable( actor ), result_str )
		target:DeltaTrust( trust )
		actor:GainXP( trust )
	else
		Msg:Echo( actor, "You try to befriend {1.Id}, but {1.heshe} seems indifferent. ({2})", target:LocTable( actor ), result_str )
	end
end

