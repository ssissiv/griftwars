local ShoddyRope = class( "Object.ShoddyRope", Object )

ShoddyRope.carrier_handlers =
{
	[ CALC_EVENT.STAT ] = function( self, agent, event_name, acc, stat )
		if stat == SKILL.CLIMBING then
			acc:AddValue( 10, self )
		end
	end,
}

function ShoddyRope:init()
	Object.init( self )
	self:GainAspect( Aspect.Carryable() )
end

function ShoddyRope:GetName()
	return "Shoddy Rope"
end

function ShoddyRope:GetValue()
	return 10
end


----------------------------------------------------------
