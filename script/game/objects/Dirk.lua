local Dirk = class( "Weapon.Dirk", Object )

Dirk.image = assets.IMG.DIRK
Dirk.attack_power = 3
Dirk.desc = "A crude weapon."

function Dirk:init()
	Object.init( self )
	self.value = 12

	self:GainAspect( Aspect.Wearable( EQ_SLOT.WEAPON ))
	self:GainAspect( Aspect.Carryable() )
end

function Dirk:GetName()
	return "dirk"
end

------------------------------------------------------------------

local JaggedDirk = class( "Weapon.JaggedDirk", Object )

JaggedDirk.image = assets.IMG.DIRK
JaggedDirk.attack_power = 4
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

function JaggedDirk:init()
	Object.init( self )
	self.value = 35

	self:GainAspect( Aspect.Wearable( EQ_SLOT.WEAPON ))
	self:GainAspect( Aspect.Carryable() )
end

JaggedDirk.desc = "75%% to cause Bleed on a successful attack."

function JaggedDirk:GetName()
	return "jagged dirk"
end
