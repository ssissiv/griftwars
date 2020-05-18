local ShoddyRope = class( "Object.ShoddyRope", Object )

ShoddyRope.event_handlers =
{
	[ CALC_EVENT.STAT ] = function( self, agent, event_name, acc, stat )
		if stat == STAT.CLIMBING then
			acc:AddValue( 10, self )
		end
	end,
}

function ShoddyRope:init()
	Object.init( self )
	self:GainAspect( Aspect.Carryable() )
end

function ShoddyRope:AssignCarrier( carrier )
	if self.carrier and is_instance( self.carrier.owner, Agent ) then
		self.carrier.owner:RemoveListener( self )
	end

	Object.AssignCarrier( self, carrier )

	if is_instance( carrier.owner, Agent ) then
		for ev, fn in pairs( self.event_handlers ) do
			carrier.owner:ListenForEvent( CALC_EVENT.STAT, self, fn )
		end
	end
end

function ShoddyRope:GetName()
	return "Shoddy Rope"
end

function ShoddyRope:GetValue()
	return 10
end


----------------------------------------------------------
