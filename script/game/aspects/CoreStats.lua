require "game/aspects/statvalue"

local Strength = class( "Aspect.Strength", Aspect.StatValue )

Strength.event_handlers =
{
	[ CALC_EVENT.ATTACK_POWER ] = function( self, agent, event_name, acc )
		acc:AddValue( self:GetValue(), self )
	end,
}

function Strength:init( value )
	Strength._base.init( self, CORE_STAT.STRENGTH, value )
	self:SetGrowthRate( 1.0 )
end

---------------------------------------------------------------------------

local Charisma = class( "Aspect.Charisma", Aspect.StatValue )

Charisma.event_handlers =
{
}

function Charisma:init( value )
	Charisma._base.init( self, CORE_STAT.CHARISMA, value )
	self:SetGrowthRate( 1.0 )
end
