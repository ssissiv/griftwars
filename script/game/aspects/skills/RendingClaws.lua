
local RendingClaws = class( "Skill.RendingClaws", Aspect.Skill )

RendingClaws.desc = "Unarmed attacks gain 5 damage, and can cause Bleed."
RendingClaws.name = "Rending Claws"

RendingClaws.event_handlers =
{
 	[ CALC_EVENT.DAMAGE ] = function( self, event_name, agent, acc, actor, target )
 		if actor == self.owner and actor:IsUnarmed() then
	    	acc:AddValue( 5, self, self:GetName() )
	    end
    end,

	[ AGENT_EVENT.POST_ATTACK ] = function( self, event_name, actor, target, attack, success )
		if success and not target:IsDead() then
			local stacks = math.random( 0, 3 )
			if stacks > 0 then
				Msg:EchoTo( actor, "Your claws gash your victim!" )
				target:GainStatusEffect( StatusEffect.Bleed, stacks )
			end
		end
	end,
}

function RendingClaws:init()
	Aspect.Skill.init( self, self._classname, 1, 1 )
end
