local FactionData = class( "FactionData" )

function FactionData:init( name )
	self.name = name
	self.enemies = {}
	self.allies = {}
end

function FactionData:AddEnemy( enemy )
	table.insert( self.enemies, enemy )
	table.insert( enemy.enemies, self )
end

function FactionData:AddAlly( ally )
	table.insert( self.allies, ally )
	table.insert( ally.allies, self )
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

function Faction:IsEnemy( other )
	assert( is_instance( other, Faction ))
	return table.contains( self.faction.enemies, other )
end

function Faction:IsAlly( other )
	assert( is_instance( other, Faction ))
	return self.faction == other.faction or table.contains( self.faction.allies, other )
end

function Faction:AssignFaction( agent )
	local faction = agent:GetAspect( Aspect.Faction )
	if faction then
		faction.faction = self.faction
	else
		faction = agent:GainAspect( Aspect.Faction( self.faction ))
	end

	return faction -- return agent's Aspect.Faction
end
