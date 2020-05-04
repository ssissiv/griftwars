local Punch = class( "Attack.Punch", Verb )

function Punch:Interact( actor, target )
	target = target or self.obj

	self:YieldForTime( ONE_MINUTE )
	if self:IsCancelled() then
		return
	end

	print( "POW!", actor, target, Calendar.FormatTime( self:GetWorld():GetDateTime() ) )
	Msg:ActToRoom( "{1.Id} attacks {2.Id}!", actor, target )
	Msg:Echo( actor, loc.format( "You attack {1.Id}!", target:LocTable( actor ) ))
	Msg:Echo( target, loc.format( "{1.Id} attacks you!", actor:LocTable( target ) ))

	target:DeltaHealth( -1 )
end
