local PackBonus = class( "Aspect.PackBonus", Aspect )

PackBonus.event_handlers =
{
	[ CALC_EVENT.ATTACK_POWER ] = function( self, agent, event_name, acc )
		-- Count adjacent allied NPCs around our target.		
		acc:AddValue( 1, self )
	end,
}
