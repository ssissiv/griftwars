local Grifter = class( "Agent.Grifter", Agent )
Grifter.unfamiliar_desc = "grifter"
Grifter.image = assets.TILE_IMG.PLAYER

function Grifter:init()
	Agent.init( self )

	Agent.MakeHuman( self )

	self:SetDetails( "Han", nil, GENDER.MALE )
	self:GainAspect( Aspect.Player() )

	self:CreateStat( STAT.XP, 0 )
	self:GetStat( STAT.HEALTH ):DeltaValue( 10, 10 )

	self:GetInventory():DeltaMoney( 2 )

	local dirk = Weapon.JaggedDirk()
	self:GetInventory():AddItem( dirk )
	dirk:GetAspect( Aspect.Wearable ):Equip()

	self:GainAspect( Skill.Backstab() )
	
	self:GainAspect( Verb.Befriend() )
end

function Grifter:GetMapChar()
	return "@"
end
