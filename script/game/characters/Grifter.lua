local Grifter = class( "Agent.Grifter", Agent )

function Grifter:init()
	Agent.init( self )

	Agent.MakeHuman( self )

	self:SetDetails( "Han", nil, GENDER.MALE )
	self:GainAspect( Aspect.Player() )

	self:CreateStat( STAT.XP, 0, 100 )
	self:GetStat( STAT.HEALTH ):DeltaValue( 500, 500 )

	self:GetInventory():DeltaMoney( 10 )
	self:GetInventory():AddItem( Weapon.Dirk() )
end

function Grifter:GetMapChar()
	return "@"
end
