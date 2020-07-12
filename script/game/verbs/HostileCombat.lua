local HostileCombat = class( "Verb.HostileCombat", Verb )

function HostileCombat:init()
	Verb.init( self )
	self.travel = Verb.Travel()
end

function HostileCombat:GetDesc( viewer )
	return "Fighting!"
end

function HostileCombat:CalculateUtility( actor )
	return UTILITY.COMBAT
end

function HostileCombat:CanInteract( actor )
	if not actor:IsSpawned() then
		return false
	elseif not actor:GetAspect( Aspect.Combat ):HasTargets() then
		return false, "No targets"
	end

	return true
end

function HostileCombat:PickAttack( actor )
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

	self.attacks = attacks
	
	return self:GetWorld():ArrayPick( attacks )
end

function HostileCombat:GetCurrentAttack()
	return self.current_attack
end

function HostileCombat:Interact( actor )
	-- self:YieldForTime( ONE_MINUTE )

	if self:IsCancelled() then
		return
	end

	local attack = self:PickAttack( actor )
	if attack then
		local target = attack:GetTarget()
		assert( target, tostring(attack) )
		actor:GetAspect( Aspect.Combat ):SetCurrentAttack( attack )
		assert( attack.InAttackRange, tostr(attack))
		if not attack:InAttackRange( actor, target ) then
			local ok, reason = self:DoChildVerb( self.travel, target )
		else
			self:DoChildVerb( attack, attack:GetTarget() )
		end
		if actor:GetAspect( Aspect.Combat ) then
			actor:GetAspect( Aspect.Combat ):SetCurrentAttack( nil )
		end
	end
end
