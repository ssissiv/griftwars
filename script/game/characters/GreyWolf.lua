
local GreyWolf = class( "Agent.GreyWolf", Agent )
GreyWolf.unfamiliar_desc = "grey wolf"

function GreyWolf:init()
	Agent.init( self )

	Agent.MakeAnimal( self )

	self:GainAspect( Aspect.Behaviour() )
	self:GetStat( STAT.HEALTH ):DeltaValue( 12, 12 )
	self:GetStat( CORE_STAT.STRENGTH ):DeltaValue( 2 )

	self:SetFeral( true )
end

function GreyWolf:GetMapChar()
	return "g", constants.colours.LT_GRAY
end

function GreyWolf:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A hungry wolf. Aren't they all?", GENDER.MALE )
end

