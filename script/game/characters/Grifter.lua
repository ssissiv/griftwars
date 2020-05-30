local Grifter = class( "Agent.Grifter", Agent )
Grifter.unfamiliar_desc = "grifter"

function Grifter:init()
	Agent.init( self )

	Agent.MakeHuman( self )

	self:SetDetails( "Han", nil, GENDER.MALE )
	self:GainAspect( Aspect.Player() )

	self:CreateStat( STAT.XP, 0, 100 )
	self:GetStat( STAT.HEALTH ):DeltaValue( 10, 10 )

	self:GetInventory():DeltaMoney( 2 )
	self:GetInventory():AddItem( Weapon.Dirk() )
end

function Grifter:GetMapChar()
	return "@"
end
