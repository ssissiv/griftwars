local Grifter = class( "Agent.Grifter", Agent )
Grifter.unfamiliar_desc = "grifter"
Grifter.image = assets.TILE_IMG.PLAYER

Grifter.charisma = 2
Grifter.strength = 2

function Grifter:init()
	Agent.init( self )

	Agent.MakeHuman( self )

	self:SetDetails( "Han", nil, GENDER.MALE )

	self:CreateStat( STAT.XP, 0 )
	self:GetStat( STAT.HEALTH ):DeltaValue( 10, 10 )

	-- Equipment
	self:GetInventory():DeltaMoney( 2 )
	self:EquipItem( Weapon.Dirk() )

	-- self:GainAspect( Skill.Hamstring() )
	-- self:GainAspect( Skill.Puncture() )
	
	self:GainAspect( Verb.Befriend() )
end

function Grifter:GetMapChar()
	return "@"
end
