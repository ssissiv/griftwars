local HostileCombat = class( "Verb.HostileCombat", Verb )

function HostileCombat:init( actor )
	Verb.init( self, actor )
	self.travel = Verb.Travel( actor )
end

function HostileCombat:GetDesc( viewer )
	return "Fighting!"
end

function HostileCombat:CalculateUtility()
	local attacks = self:CollectAttacks( self.actor )
	local attack_utility = attacks[1] and attacks[1]:GetUtility() or 0
	return UTILITY.COMBAT + attack_utility
end

function HostileCombat:CanInteract()
	local actor = self.actor
	if not actor:IsSpawned() then
		return false
	elseif not actor:GetAspect( Aspect.Combat ):HasTargets() then
		return false, "No targets"
	end

	return true
end

function HostileCombat:CollectAttacks( actor )
	local combat = actor:GetAspect( Aspect.Combat )
	local attacks = {}
	for i, target in combat:Targets() do
		actor:RegenVerbs( "attacks" )
		local verbs = actor:GetPotentialVerbs( "attacks", target )
		for i, verb in verbs:Verbs() do
			if verb.InAttackRange then -- TODO: this is dumb, GetPotentialVerbs shouldn't harvest non-attacks
				if verb.CalculateUtility then
					verb:SetUtility( verb:CalculateUtility())
				end
				table.insert( attacks, verb )
			end
		end
	end

	table.sort( attacks, Verb.SortByUtility )

	return attacks
end

function HostileCombat:GetCurrentAttack()
	return self.current_attack
end

function HostileCombat:Interact()
	local actor = self.actor
	self.attacks = self:CollectAttacks( actor )
	local attack = self.attacks[1]
	if attack then
		local target = attack:GetTarget()
		assert( target, tostring(attack) )
		actor:GetAspect( Aspect.Combat ):SetCurrentAttack( attack )

		-- Move into attack range if possible.
		if not attack:InAttackRange( actor, target ) then
			self.travel:SetApproachDistance( attack:GetAttackRange() )
			self.travel:SetDest( target )
			local ok, reason = self:DoChildVerb( self.travel )
		end

		-- Atttaaack.
		if not self:IsCancelled() then
			self:DoChildVerb( attack )
		end

		if actor:GetAspect( Aspect.Combat ) then
			actor:GetAspect( Aspect.Combat ):SetCurrentAttack( nil )
		end
	end
end
