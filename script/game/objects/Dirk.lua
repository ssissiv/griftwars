local Dirk = class( "Weapon.Dirk", Object )

Dirk.equipment_handlers =
{
	[ CALC_EVENT.ATTACK_POWER ] = function( self, agent, event_name, acc )
		acc:AddValue( 3, self )
	end,
}

function Dirk:init()
	Object.init( self )
	self.value = 12

	self:GainAspect( Aspect.Wearable( EQ_SLOT.WEAPON ))
	self:GainAspect( Aspect.Carryable() )
end

function Dirk:GetName()
	return "dirk"
end
