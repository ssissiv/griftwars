
---------------------------------------------------------------------

local CityGuard = class( "Agent.CityGuard", Agent )

CityGuard.MAP_CHAR = "g"
CityGuard.unfamiliar_desc = "city guard"

function CityGuard:init()
	Agent.init( self )
	
	self:MakeHuman()

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Skill.Fighting() )
end

function CityGuard:GetLongDesc()
	return loc.format( "City Guard of {1}", self:GetAspect( Aspect.FactionMember ):GetName() )
end
