
local Fighter = class( "Skill.Fighter", Aspect.Skill )

Fighter.event_handlers =
{
 	[ CALC_EVENT.ATTACK_POWER ] = function( self, agent, event_name, acc )
    	acc:AddValue( self:GetSkillRank(), self )
    end,
}

function Fighter:init()
	Aspect.Skill.init( self, SKILL.FIGHTING, 1, 5 )
	self:SetGrowthRate( 0.1 )
end
