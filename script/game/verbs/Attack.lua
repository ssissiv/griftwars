local Attack = class( "Verb.Attack", Verb )

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

function Attack:InAttackRange( actor, target )
	local x1, y1 = actor:GetCoordinate()
	local x2, y2 = target:GetCoordinate()
	if distance( x1, y1, x2, y2 ) <= 2 then
		return true
	else
		return false
	end
end

function Attack:Interact( actor, target )
	target = target or self.obj
	-- self:YieldForTime( ONE_MINUTE )

	if self:IsCancelled() then
		return
	end

	local combat = actor:GetAspect( Aspect.Combat )

	local attacks = {}
	for i, target in combat:Targets() do
		local verbs = actor:GetPotentialVerbs( nil, target )
		for i, verb in verbs:Verbs() do
			print( actor, target, verb, target:IsSpawned(), verb:CanDo( actor, target ))
			if is_instance( verb, Attack.Punch ) and verb:CanDo( actor, target ) then
				table.insert( attacks, verb )
			end
		end
	end

	local attack = self:GetWorld():ArrayPick( attacks )
	if attack then
		attack:DoVerb( actor, attack:GetTarget() )
	end
end
