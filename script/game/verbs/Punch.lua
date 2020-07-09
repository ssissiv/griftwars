local Punch = class( "Attack.Punch", Verb )

Punch.DC = 5
Punch.INTENT_FLAGS = INTENT.HOSTILE

function Punch:init( target )
	Verb.init( self, nil, target )
	self.fatigue_cost = 5
end


function Punch:InAttackRange( actor, target )
	local x1, y1 = actor:GetCoordinate()
	local x2, y2 = target:GetCoordinate()
	if distance( x1, y1, x2, y2 ) > 1.5 then
		return false, "Out of range"
	end

	return true
end

function Punch:GetDesc( viewer )
	local wpn = self.actor:GetWeapon()
	if wpn then
		return loc.format( "Attacking ({1})", wpn:GetName( viewer ) )
	else
		return "Attacking unarmed"
	end
end

function Punch:GetRoomDesc( viewer )
	if self.obj then
		return loc.format( "Punch for {1} damage", self:CalculateDamage( self.obj ))
	else
		return "Punch"
	end
end	

function Punch:OnCancel()
	if self.obj and self.obj:IsDead() then
		return
	end

	-- TODO: should only be certain reasons really, like out of range.
	Msg:Echo( self.actor, "You mutter as your attack is foiled." )
	if self.obj then
		Msg:Echo( self.obj, "{1.Id} mutters as their attack is cancelled.", self.actor:LocTable( self.obj ))
	end
end

function Punch:CanInteract( actor, target )
	target = target or self.obj

	local ok, reason = Verb.CanInteract( self, actor, target )
	if not ok then
		return false, reason
	end

	if not actor:HasEnergy( self.fatigue_cost ) then
		return false, "Too tired"
	end

	if not self:InAttackRange( actor, target ) then
		return false, "Out of range"
	end

	return true	
end

function Punch:GetDuration()
	return ATTACK_TIME
end

function Punch:CalculateDamage( target )
	local ap = self.actor:CalculateAttackPower()
	local all_details = loc.format( "Attack Power: {1}", ap )

	local acc = self.actor:GetAspect( Aspect.ScalarCalculator )
	local damage, details = acc:CalculateValue( CALC_EVENT.DAMAGE, ap, target )
	
	local acc = target:GetAspect( Aspect.ScalarCalculator )
	local damage, details2 = acc:CalculateValue( CALC_EVENT.DAMAGE, damage, target )

	if details and details2 then
		all_details = all_details .."\n" .. details .. "\n" .. details2
	elseif details then
		all_details = all_details .."\n" .. details
	elseif details2 then
		all_details = all_details .."\n" .. details2
	end

	damage = math.max( 0, damage )

	return damage, all_details
end

function Punch:Interact( actor, target )
	target = target or self.obj

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

	actor:GetStat( STAT.FATIGUE ):DeltaValue( -self.fatigue_cost )

	-- Check success.
	if ok then
		Msg:ActToRoom( "{1.Id} attacks {2.Id} for {3} damage!", actor, target, damage )
		Msg:Echo( actor, loc.format( "You attack {1.Id} for {2} damage! ({3})", target:LocTable( actor ), damage, result_str ))
		Msg:Echo( target, loc.format( "{1.Id} attacks you! ({2} damage)", actor:LocTable( target ), damage ))

		target:DeltaHealth( -damage )

		if target:IsDead() then
			target:BroadcastEvent( AGENT_EVENT.KILLED, actor, self )
		end

	else
		Msg:Echo( actor, loc.format( "You miss {1.Id}. ({2})", target:LocTable( actor ), result_str ))
		Msg:Echo( target, loc.format( "{1.Id} misses you with {1.hisher} {2}.", actor:LocTable( target ), self ))
	end

	actor:BroadcastEvent( AGENT_EVENT.POST_ATTACK, target, self, ok )

	self:YieldForTime( self:GetDuration() )
end

function Punch:RenderTooltip( ui, viewer )
	local damage, details = self:CalculateDamage( self.obj )
	ui.Text( tostring(details) )
end
