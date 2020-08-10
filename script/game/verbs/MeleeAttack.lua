local MeleeAttack = class( "Verb.MeleeAttack", Verb )

MeleeAttack.INTENT_FLAGS = INTENT.HOSTILE
MeleeAttack.act_desc = "Attack"

function MeleeAttack:init( actor, target )
	Verb.init( self, actor )
	assert( target )
	self.target = target
	self.fatigue_cost = 5
end

function MeleeAttack:GetTarget()
	return self.target
end

function MeleeAttack:GetAttackRange()
	local wpn = self.actor:GetWeapon()
	local range = wpn and wpn:GetAttackRange() or 1.5
	return range
end

function MeleeAttack:InAttackRange( actor, target )
	local range = self:GetAttackRange()
	local x1, y1 = actor:GetCoordinate()
	local x2, y2 = target:GetCoordinate()
	if distance( x1, y1, x2, y2 ) > range then
		return false, "Out of range"
	end

	return true
end

function MeleeAttack:CalculateUtility()
	if self:InAttackRange( self.actor, self.target ) then
		return 50
	end

	return 0
end

function MeleeAttack:GetDesc( viewer )
	local wpn = self.actor:GetWeapon()
	if wpn then
		return loc.format( "Attacking ({1})", wpn:GetName( viewer ) )
	else
		return "Attacking unarmed"
	end
end

function MeleeAttack:GetActDesc( actor )
	if self.target then
		return loc.format( "{1} for {2} damage", self.act_desc, self:CalculateDamage( self.target ))
	else
		return "Attack"
	end
end	

function MeleeAttack:OnCancel()
	if self.target and self.target:IsDead() then
		return
	end

	-- TODO: should only be certain reasons really, like out of range.
	Msg:EchoTo( self.actor, "You mutter as your attack is foiled." )
	if self.target then
		Msg:EchoTo( self.target, "{1.Id} mutters as their attack is cancelled.", self.actor:LocTable( self.target ))
	end
end

function MeleeAttack:CanInteract()
	assert( self.actor )
	local ok, reason = Verb.CanInteract( self )
	if not ok then
		return false, reason
	end

	if not self.actor:HasEnergy( self.fatigue_cost ) then
		return false, "Too tired"
	end

	if not self:InAttackRange( self.actor, self.target ) then
		return false, "Out of range"
	end

	return true	
end

function MeleeAttack:GetDuration()
	return ATTACK_TIME
end

function MeleeAttack:CalculateDamage( target )
	local ap = self.actor:CalculateAttackPower()
	local acc = self.actor:GetAspect( Aspect.DamageCalculator ) or self.actor:GainAspect( Aspect.DamageCalculator() )

	acc:InitializeValue( ap )
	acc:AddSource( loc.format( "Attack Power: {1}", ap ))
	if self.piercing then
		acc:SetPiercing( self.piercing, self, self.act_desc )
	end

	acc:CalculateValueFromSources( self.actor, CALC_EVENT.DAMAGE, self.actor, target )

	local damage, details = acc:CalculateValueFromSources( target, CALC_EVENT.DAMAGE, self.actor, target )

	damage = math.max( 0, damage )

	return damage, details
end

function MeleeAttack:CalculateDC()
	return 5
end

function MeleeAttack:Interact()
	local actor, target = self.actor, self.target
	local damage = self:CalculateDamage( target )
	local ok, result_str = self:CheckDC( actor, target )

	actor:BroadcastEvent( AGENT_EVENT.PRE_ATTACK, target, self, ok )
	target:BroadcastEvent( AGENT_EVENT.ATTACKED, actor, self, ok )

	if actor:IsDead() or target:IsDead() or self:IsCancelled() then
		self:OnCancel()
		return
	end

	target:GetMemory():AddEngram( Engram.HasAttacked( actor ))
	target:GetAspect( Aspect.Combat ):EvaluateTargets()

	actor:GetStat( STAT.FATIGUE ):DeltaValue( self.fatigue_cost )

	-- Check success.
	if ok then
		self.total_damage = damage

		Msg:EchoAround2( actor, target, "{1.Id} attacks {2.Id} for {3} damage!", actor, target, damage )
		Msg:EchoTo( actor, loc.format( "You attack {1.Id} for {2} damage! ({3})", target:LocTable( actor ), damage, result_str ))
		Msg:EchoTo( target, loc.format( "{1.Id} attacks you! ({2} damage)", actor:LocTable( target ), damage ))

		target:DeltaHealth( -damage )

		if target:IsDead() then
			target:BroadcastEvent( AGENT_EVENT.KILLED, actor, self )
		end

	else
		self.total_damage = nil
		Msg:EchoTo( actor, loc.format( "You miss {1.Id}. ({2})", target:LocTable( actor ), result_str ))
		Msg:EchoTo( target, loc.format( "{1.Id} misses you.", actor:LocTable( target )))
	end

	actor:BroadcastEvent( AGENT_EVENT.POST_ATTACK, target, self, ok )

	self:YieldForTime( self:GetDuration() )
end

function MeleeAttack:RenderTooltip( ui, viewer )
	local damage, details = self:CalculateDamage( self.target )
	ui.Text( tostring(details) )
end
