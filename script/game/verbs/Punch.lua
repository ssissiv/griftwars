local Punch = class( "Attack.Punch", Verb )

function Punch:InAttackRange( actor, target )
	local x1, y1 = actor:GetCoordinate()
	local x2, y2 = target:GetCoordinate()
	return distance( x1, y1, x2, y2 ) <= 2, "Out of range"
end

function Punch:GetDesc( viewer )
	return "Punch"
end	

function Punch:CanInteract( actor, target )
	local ok, reason = Verb.CanInteract( self, actor, target )
	if not ok then
		return false, reason
	end

	if not self:InAttackRange( actor, target ) then
		return false, "Out of range"
	end

	return true	
end

function Punch:GetDuration()
	return ATTACK_TIME
end

function Punch:Interact( actor, target )
	target = target or self.obj

	local damage = actor:CalculateAttackDamage()
	Msg:ActToRoom( "{1.Id} attacks {2.Id} for {3} damage!", actor, target, damage )
	Msg:Echo( actor, loc.format( "You attack {1.Id}! ({2} damage)", target:LocTable( actor ), damage ))
	Msg:Echo( target, loc.format( "{1.Id} attacks you! ({2} damage)", actor:LocTable( target ), damage ))

	target:DeltaHealth( -damage )

	self:YieldForTime( self:GetDuration() )
end
