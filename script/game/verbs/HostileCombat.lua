local HostileCombat = class( "Verb.HostileCombat", Verb.CombatPolicy )

function HostileCombat:init( actor )
	Verb.init( self, actor )
	self.travel = Verb.Travel( actor )
end

function HostileCombat:GetDesc( viewer )
	return "Fighting!"
end

function HostileCombat:CalculatePolicyUtility()
	local attacks = self:CollectAttacks( self.actor )
	local attack_utility = attacks[1] and attacks[1]:GetUtility() or 0
	return UTILITY.COMBAT + attack_utility
end

function HostileCombat:CanInteract()
	local actor = self.actor
	if not actor:IsSpawned() then
		return false
	elseif not actor.combat then
		return false, "no combat"
	elseif not actor.combat:HasTargets() then
		return false, "No targets"
	end

	self.attacks = self:CollectAttacks( actor )
	if #self.attacks == 0 then
		return false, "No attacks"
	end

	return true --HostileCombat._base.CanInteract( self )
end

function HostileCombat:CollectAttacks( actor )
	local combat = actor:GetAspect( Verb.Combat )
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

function HostileCombat:Interact()
	local actor = self.actor
	local attack = self.attacks[1]
	assert( attack )
	local target = attack:GetTarget()
	assert( target, tostring(attack) )
	actor:GetAspect( Verb.Combat ):SetCurrentAttack( attack )

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

	if actor:GetAspect( Verb.Combat ) then
		actor:GetAspect( Verb.Combat ):SetCurrentAttack( nil )
	end
end

