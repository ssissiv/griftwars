
local BrownBear = class( "Agent.BrownBear", Agent )
BrownBear.short_desc = "brown bear"

function BrownBear:init()
	Agent.init( self )

	Agent.MakeAnimal( self )

	self:GainAspect( Aspect.Behaviour() )
	self:GetStat( STAT.HEALTH ):DeltaValue( 50, 50 )
	self:GetStat( STAT.STRENGTH ):DeltaValue( 4 )

	self:SetFeral( true )
end

function BrownBear:GetMapChar()
	return "B", constants.colours.BROWN
end

function BrownBear:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A big hungry, furry brute.", GENDER.MALE )
end
