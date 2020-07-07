
local Backstab = class( "Skill.Backstab", Aspect.Skill )

Backstab.desc = "Your damage is doubled against targets not in combat with you."
Backstab.name = "Backstab"

Backstab.event_handlers =
{
 	[ CALC_EVENT.DAMAGE ] = function( self, event_name, agent, acc, target )
 		if target and not target:InCombatWith( self.owner ) then
	    	acc:AddValue( acc.value, self, self:GetName() )
	    end
    end,
}

function Backstab:init()
	Aspect.Skill.init( self, self._classname, 1, 3 )
	self:SetGrowthRate( 0.1 )
end
