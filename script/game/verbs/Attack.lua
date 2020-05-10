local Attack = class( "Verb.Attack", Verb )

function Attack:init( target )
	Verb.init( self, nil, target )
	self.travel = self:AddChildVerb( Verb.Travel() )
end

function Attack:GetShortDesc( viewer )
	if viewer == self:GetOwner() then
		return "You are attacking!"
	else
		return loc.format( "{1.Id} is here attacking!", self.actor:LocTable( viewer ))
	end
end

function Attack:CalculateUtility( actor )
	return UTILITY.COMBAT
end

function Attack:CanInteract( actor )
	if not actor:IsSpawned() then
		return false
	elseif not actor:GetAspect( Aspect.Combat ):HasTargets() then
		return false, "No targets"
	end

	return true
end

function Attack:PickAttack( actor, target )
	local combat = actor:GetAspect( Aspect.Combat )
	local attacks = {}
	for i, target in combat:Targets() do
		local verbs = actor:GetPotentialVerbs( nil, target )
		for i, verb in verbs:Verbs() do
			if verb.InAttackRange then -- and verb:CanDo( actor, target ) then
				table.insert( attacks, verb )
			end
		end
	end

	return self:GetWorld():ArrayPick( attacks )
end

function Attack:Interact( actor, target )
	target = target or self.obj
	-- self:YieldForTime( ONE_MINUTE )

	if self:IsCancelled() then
		return
	end

	local attack = self:PickAttack( actor, target )
	if attack then
		assert( attack.InAttackRange, tostr(attack))
		if not attack:InAttackRange( actor, target ) then
			local ok, reason = self.travel:DoVerb( actor, target )
			print( "atk", target, ok, reason )
		else
			attack:DoVerb( actor, attack:GetTarget() )
		end
	end
end
