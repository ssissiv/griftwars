local Armour = class( "Object.Armour", Object )

function Armour:init()
	Object.init( self )

	self:GainAspect( Aspect.Wearable( EQ_SLOT.BODY ))
	self:GainAspect( Aspect.Carryable() )
end

Armour.equipment_handlers =
{
	[ CALC_EVENT.DAMAGE ] = function( self, event_name, agent, acc, actor, target )
		if target == self.carrier.owner and self:GetAspect( Aspect.Wearable ):IsEquipped() then
			acc:AddValue( -self.defense_power, self, self:GetName() )
		end
	end
}
