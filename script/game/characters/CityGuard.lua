
---------------------------------------------------------------------

local CityGuard = class( "Agent.CityGuard", Agent )

CityGuard.MAP_CHAR = "c"
CityGuard.short_desc = "city guard"

function CityGuard:init()
	Agent.init( self )
	
	self:MakeHuman()

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Skill.Fighter() )
end
