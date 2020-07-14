require "game/verbs/MeleeAttack"

local Hamstring = class( "Verb.Hamstring", Verb.MeleeAttack )

Hamstring.act_desc = "Hamstring"

function Hamstring:Interact( actor, target )
	Hamstring._base.Interact( self, actor, target )

	if self.total_damage and not target:HasAspect( StatusEffect.Hobbled ) then
		Msg:Echo( actor, "Your attack hobbles your victim's movement!" )
		target:GainStatusEffect( StatusEffect.Hobbled, 1 )
	end
end