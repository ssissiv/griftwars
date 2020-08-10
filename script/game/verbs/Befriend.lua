
local Befriend = class( "Verb.Befriend", Verb )

Befriend.INTENT_FLAGS = INTENT.DIPLOMACY
Befriend.can_repeat = true -- This interaction can take place multiple times.

function Befriend:GetActDesc()
	return loc.format( "Befriend {1}", self.target:LocTable( self.actor ))
end

function Befriend:CalculateUtility()
	return UTILITY.FUN
end

function Befriend:CanInteract()
	local actor, target = self.actor, self.target
	if not target then
		return false
	end
	if not target:IsAlert() then
		return false, "Not alert"
	end
	local affinity = target:GetAffinity( actor )
	if affinity == AFFINITY.FRIEND then
		return false
	end
	if not target:CanSpeak() then
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

	return Verb.CanInteract( self )
end

function Befriend:CollectVerbs( verbs, actor, obj )
	if actor == self.owner and obj ~= actor and is_instance( obj, Agent ) and not obj:IsDead() then
		self.actor, self.target = actor, obj
		verbs:AddVerb( self )
	end
end

function Befriend:CalculateDC()
	local acc = self.actor:GetAspect( Aspect.ScalarCalculator )
	acc:CalculateValue( CALC_EVENT.BEFRIEND, 10 )
	
	local count = self.target:GetMemory():CountEngrams( Engram.Befriended.Find, self.actor )
	if count > 0 then
		acc:AddValue( count, self, loc.format( "{1} attempts within the last day", count ))
	end

	-- Faction Role Modiifer
	local faction = self.target:GetAspect( Aspect.FactionMember )
	if faction and faction:GetRole() then
		local tier = FACTION_TIERS[ faction:GetRole() ]
		acc:AddValue( tier * 5, self, loc.format( "Faction Tier: {1} ({2})", tier, faction:GetRole() ))
	end

	-- InsideInfo.
	if faction then
		local count = self.actor:GetMemory():CountEngrams( function( e ) return is_instance( e, Engram.InsideInfo ) and e.faction == faction.faction end )
		if count > 0 then
			acc:AddValue( count * -5, self, loc.format( "Inside Info (x{1})", count ))
		end
	end

	local dc, details = acc:GetValue()
	local fail_str = count > 0 and "Lose 1 Trust"
	return dc, details, fail_str
end

function Befriend:Interact( actor, target )
	local actor, target = self.actor, self.target

	-- self:AttachActor( target )

	-- self:YieldForTime( 10 * ONE_MINUTE, "wall", 1.0 )

	if self:IsCancelled() then
		Msg:EchoTo( actor, "So much for making friends." )
		return
	end

	local ok, result_str = self:CheckDC()
	if ok then
		local trust = actor:GetStatValue( CORE_STAT.CHARISMA )

		Msg:EchoTo( actor, "You befriend {1.Id}. ({2})", target:LocTable( actor ), result_str )
		target:DeltaTrust( trust )
		actor:GainXP( trust )
	elseif target:GetMemory():FindEngram( Engram.Befriended.Find, self.actor ) then
		Msg:EchoTo( actor, "You try to befriend {1.Id}, but {1.heshe} seems rather annoyed. ({2})", target:LocTable( actor ), result_str )
		target:DeltaTrust( -1 )
	else
		Msg:EchoTo( actor, "You try to befriend {1.Id}, but {1.heshe} seems indifferent. ({2})", target:LocTable( actor ), result_str )
	end

	target:AddEngram( Engram.Befriended( actor ))
end

