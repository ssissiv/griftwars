local Punch = class( "Attack.Punch", Verb )

function Punch:CanInteract( actor, target )
	local x1, y1 = actor:GetCoordinate()
	local x2, y2 = target:GetCoordinate()
	return distance( x1, y1, x2, y2 ) <= 2, "Out of range"
end

function Punch:Interact( actor, target )
	target = target or self.obj

	Msg:ActToRoom( "{1.Id} attacks {2.Id}!", actor, target )
	Msg:Echo( actor, loc.format( "You attack {1.Id}!", target:LocTable( actor ) ))
	Msg:Echo( target, loc.format( "{1.Id} attacks you!", actor:LocTable( target ) ))

	target:DeltaHealth( -1 )

	self:YieldForTime( ONE_MINUTE )
end
