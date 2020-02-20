local FactionData = class( "FactionData" )

function FactionData:init( name )
	self.name = name
end

function FactionData:__tostring()
	return string.format( "[Faction: %s]", self.name )
end

--------------------------------------------------------

local Faction = class( "Aspect.Faction", Aspect )

function Faction:init( faction )
	assert( is_instance( faction, FactionData ))
	self.faction = faction
end

function Faction:GetName()
	return self.faction.name
end
