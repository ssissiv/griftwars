
local GiantLizard = class( "Agent.GiantLizard", Agent )
GiantLizard.unfamiliar_desc = "giant lizard"

function GiantLizard:init()
	Agent.init( self )

	Agent.MakeAnimal( self )

	self:GetStat( STAT.HEALTH ):DeltaValue( 6, 6 )
	self:GetStat( CORE_STAT.STRENGTH ):DeltaValue( 1 )

	self:GainAspect( Skill.ScalyHide() )
end

function GiantLizard:GetMapChar()
	return "l", constants.colours.GREEN
end
