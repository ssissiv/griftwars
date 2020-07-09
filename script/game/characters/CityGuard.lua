
---------------------------------------------------------------------

local CityGuard = class( "Agent.CityGuard", Agent )

CityGuard.MAP_CHAR = "g"
CityGuard.unfamiliar_desc = "city guard"
CityGuard.max_health = 20

function CityGuard:init()
	Agent.init( self )
	
	self:MakeHuman()

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Skill.Fighting() )

	Aspect.Favour.GainFavours( self,
	{
		{ Favour.Acquaint(), 10 },
		{ Favour.NonAggression( 100 ), 20 },
	})
end
