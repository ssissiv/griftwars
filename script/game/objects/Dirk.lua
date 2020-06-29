local Dirk = class( "Weapon.Dirk", Object )

Dirk.image = assets.IMG.DIRK

Dirk.equipment_handlers =
{
	[ CALC_EVENT.ATTACK_POWER ] = function( self, agent, event_name, acc )
		acc:AddValue( 3, self )
	end,
}

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

JaggedDirk.equipment_handlers =
{
	[ CALC_EVENT.ATTACK_POWER ] = function( self, agent, event_name, acc )
		acc:AddValue( 5, self )
	end,
}

function JaggedDirk:init()
	Object.init( self )
	self.value = 35

	self:GainAspect( Aspect.Wearable( EQ_SLOT.WEAPON ))
	self:GainAspect( Aspect.Carryable() )
end

function JaggedDirk:GetName()
	return "jagged dirk"
end
