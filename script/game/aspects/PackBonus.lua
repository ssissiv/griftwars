local PackBonus = class( "Aspect.PackBonus", Aspect )

PackBonus.event_handlers =
{
	[ CALC_EVENT.ATTACK_POWER ] = function( self, event_name, agent, acc )
		if agent == self.owner then
			-- Count adjacent allied NPCs around our target.
			local allies = 0
			for i, other in self.owner:GetLocation():Contents() do
				if other ~= self.owner and is_instance( other, self.owner._class ) and self.owner:IsAlly( other ) then
					allies = allies + 1
				end
			end
			if allies > 0 then
				acc:AddValue( allies, self )
			end
		end
	end,
}
