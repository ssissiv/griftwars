require "game/verbs/MeleeAttack"

local Puncture = class( "Verb.Puncture", Verb.MeleeAttack )

Puncture.act_desc = "Puncture"
Puncture.piercing = 1

function Puncture:CanInteract( actor, target )
	local wpn = actor:GetWeapon()
	if not wpn then
		return false, "Not wielding a stabbing weapon"
	end
	return Verb.MeleeAttack.CanInteract( self, actor, target )
end
