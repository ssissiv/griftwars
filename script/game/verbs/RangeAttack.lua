local RangeAttack = class( "Verb.RangeAttack", Verb )

RangeAttack.INTENT_FLAGS = INTENT.HOSTILE
RangeAttack.act_desc = "Attack"

function RangeAttack:init( actor, target )
	Verb.init( self, actor )
	assert( target )
	self.target = target
end

function RangeAttack:SetProjectile( proj )
	self.proj = proj
	return self
end

function RangeAttack:InAttackRange( actor, target )
	local range = self:GetAttackRange()
	local x1, y1 = actor:GetCoordinate()
	local x2, y2 = target:GetCoordinate()
	if distance( x1, y1, x2, y2 ) > range then
		return false, "Out of range"
	end

	return true
end

function RangeAttack:GetAttackRange()
	return 10
end

function RangeAttack:GetDesc( viewer )
	local wpn = self.actor:GetWeapon()
	if wpn then
		return loc.format( "Attacking ({1})", wpn:GetName( viewer ) )
	else
		return "Attacking unarmed"
	end
end

function RangeAttack:GetActDesc()
	if self.tarfget then
		return loc.format( "{1} for {2} damage", self.act_desc, self:CalculateDamage( self.target ))
	else
		return "Attack"
	end
end	

function RangeAttack:CanInteract()
	local actor, target = self.actor, self.target

	local ok, reason = Verb.CanInteract( self )
	if not ok then
		return false, reason
	end

	if not self.proj then
		return false, "No projectile"
	end
	
	if not actor:HasEnergy( self.fatigue_cost ) then
		return false, "Too tired"
	end

	if not self:InAttackRange( actor, target ) then
		return false, "Out of range"
	end

	return true	
end

function RangeAttack:GetDuration()
	return ATTACK_TIME
end

function RangeAttack:CalculateDamage( target )
	local ap = self.actor:CalculateRangeAttackPower( self.proj )
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

function RangeAttack:CalculateDC()
	return 10
end

function RangeAttack:Interact()
	local actor, target = self.actor, self.target
	local damage = self:CalculateDamage( target )
	local ok, result_str = self:CheckDC( actor, target )

	actor:BroadcastEvent( AGENT_EVENT.PRE_ATTACK, target, self, ok )
	target:BroadcastEvent( AGENT_EVENT.ATTACKED, actor, self, ok )

	if actor:IsDead() or target:IsDead() or self:IsCancelled() then
		-- self:OnCancel()
		return
	end

	target:GetMemory():AddEngram( Engram.HasAttacked( actor ))
	target:GetAspect( Aspect.Combat ):EvaluateTargets()

	actor:GetStat( STAT.FATIGUE ):DeltaValue( -self.fatigue_cost )

	-- Check success.
	if ok then
		self.total_damage = damage

		-- Whats the right way to organize this garbage?
		if is_instance( self, Verb.ThrowObject ) then
			Msg:EchoAround2( actor, target, "{1.Id} throws {4.desc} at {2.Id} for {3} damage!", actor, target, damage, self.proj )
			Msg:EchoTo( actor, loc.format( "You throw {4.desc} at {1.Id} for {2} damage! ({3})", target, damage, result_str, self.proj ))
			Msg:EchoTo( target, loc.format( "{1.Id} throws {3.desc} at you! ({2} damage)", actor:LocTable( target ), damage, self.proj ))
		else
			Msg:EchoAround2( actor, target, "{1.Id} attacks {2.Id} for {3} damage!", actor, target, damage )
			Msg:EchoTo( actor, loc.format( "You attack {1.Id} for {2} damage! ({3})", target:LocTable( actor ), damage, result_str ))
			Msg:EchoTo( target, loc.format( "{1.Id} attacks you! ({2} damage)", actor:LocTable( target ), damage ))
		end

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

function RangeAttack:RenderTooltip( ui, viewer )
	local damage, details = self:CalculateDamage( self.target )
	ui.Text( tostring(details) )
end
