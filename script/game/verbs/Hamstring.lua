require "game/verbs/MeleeAttack"

local Hamstring = class( "Verb.Hamstring", Verb.MeleeAttack )

Hamstring.act_desc = "Hamstring"

function Hamstring:Interact()
	Hamstring._base.Interact( self )

	if self.total_damage and not self.target:HasAspect( StatusEffect.Hobbled ) then
		Msg:EchoTo( self.actor, "Your attack hobbles your victim's movement!" )
		self.target:GainStatusEffect( StatusEffect.Hobbled, 1 )
	end
end