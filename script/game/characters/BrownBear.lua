
local BrownBear = class( "Agent.BrownBear", Agent )
BrownBear.unfamiliar_desc = "brown bear"

function BrownBear:init()
	Agent.init( self )

	Agent.MakeAnimal( self )

	self:GetStat( STAT.HEALTH ):DeltaValue( 50, 50 )
	self:GetStat( CORE_STAT.STRENGTH ):DeltaValue( 4 )

	self:GainAspect( Skill.RendingClaws() )

	self:SetFlags( EF.AGGRO_ALL )
	self:DeltaLevel( 8 )
end

function BrownBear:GetMapChar()
	return "B", constants.colours.BROWN
end

function BrownBear:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A big hungry, furry brute.", GENDER.MALE )
end

