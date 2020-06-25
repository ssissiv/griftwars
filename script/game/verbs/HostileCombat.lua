local HostileCombat = class( "Verb.HostileCombat", Verb )

function HostileCombat:init()
	Verb.init( self )
	self.travel = self:AddChildVerb( Verb.Travel() )
end

function HostileCombat:GetShortDesc( viewer )
	if viewer == self:GetOwner() then
		return "You are attacking!"
	else
		return loc.format( "{1.Id} is here attacking!", self.actor:LocTable( viewer ))
	end
end

function HostileCombat:RenderAgentDetails( ui, screen, viewer )
	ui.Bullet()
	ui.Text( "Fighting!" )
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
		actor:GetAspect( Aspect.Combat ):SetCurrentAttack( attack )
		assert( attack.InAttackRange, tostr(attack))
		if not attack:InAttackRange( actor, target ) then
			local ok, reason = self.travel:DoVerb( actor, target )
		else
			attack:DoVerb( actor, attack:GetTarget() )
		end
		if actor:GetAspect( Aspect.Combat ) then
			actor:GetAspect( Aspect.Combat ):SetCurrentAttack( nil )
		end
	end
end
