require "game/objects/Weapon"

local Dirk = class( "Weapon.Dirk", Object.Weapon )

Dirk.image = assets.IMG.DIRK
Dirk.attack_power = 3
Dirk.desc = "A crude weapon."
Dirk.value = 26
Dirk.name = "dirk"

------------------------------------------------------------------

local JaggedDirk = class( "Weapon.JaggedDirk", Object.Weapon )

JaggedDirk.image = assets.IMG.DIRK
JaggedDirk.attack_power = 4
JaggedDirk.value = 60
JaggedDirk.desc = "75%% to cause Bleed on a successful attack."
JaggedDirk.name = "jagged dirk"


JaggedDirk.equipment_handlers = 
{
	[ AGENT_EVENT.POST_ATTACK ] = function( self, event_name, actor, target, attack, success )
		if success and not target:IsDead() then
			local stacks = math.random( 0, 3 )
			if stacks > 0 then
				Msg:Echo( actor, "Your dirk opens a gash in your victim!" )
				target:GainStatusEffect( StatusEffect.Bleed, stacks )
			end
		end
	end,
}


