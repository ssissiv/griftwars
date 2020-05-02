local Grifter = class( "Agent.Grifter", Agent )

function Grifter:init()
	Agent.init( self )

	Agent.MakeHuman( self )

	self:SetDetails( "Han", nil, GENDER.MALE )
	self:GainAspect( Aspect.Player() )

	self:CreateStat( STAT.XP, 0, 100 )

	self:GetInventory():DeltaMoney( 10 )
end

function Grifter:GetMapChar()
	return "@"
end
