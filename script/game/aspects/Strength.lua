require "game/aspects/statvalue"

local Strength = class( "Aspect.Strength", Aspect.StatValue )

Strength.event_handlers =
{
	[ CALC_EVENT.ATTACK_POWER ] = function( self, agent, event_name, acc )
		acc:AddValue( self:GetValue(), self )
	end,
}

function Strength:init( value )
	Strength._base.init( self, STAT.STRENGTH, value, 99 )
end

