local PackBonus = class( "Aspect.PackBonus", Aspect )

PackBonus.event_handlers =
{
	[ CALC_EVENT.ATTACK_POWER ] = function( self, event_name, agent, acc )
		-- Count adjacent allied NPCs.
		local allies = 0
		for i, other in agent:GetLocation():Contents() do
			if other ~= agent and is_instance( other, agent._class ) and agent:IsAlly( other ) then
				allies = allies + 1
			end
		end
		if allies > 0 then
			acc:AddValue( allies, self )
		end
	end,
}
