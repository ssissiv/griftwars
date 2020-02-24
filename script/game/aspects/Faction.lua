local FactionData = class( "FactionData" )

function FactionData:init( name )
	self.name = name
	self.tags = {}
end

function FactionData:HasTag( faction, tag )
	assert( IsEnum( tag, FACTION_TAG ))
	local t = self.tags[ faction ]
	return t and table.contains( t, tag )
end

function FactionData:AddTag( faction, tag )
	assert( IsEnum( tag, FACTION_TAG ))
	local t = self:AffirmFaction( faction )
	table.insert_unique( t, tag )
end

function FactionData:AffirmFaction( faction )
	local t = self.tags[ faction ]
	if t == nil then
		t = {}
		self.tags[ faction ] = t
	end
	return t
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
	return self.faction:HasTag( other.faction, FACTION_TAG.ENEMY )
end

function Faction:IsAlly( other )
	assert( is_instance( other, Faction ))
	return self.faction == other.faction or	self.faction:HasTag( other, FACTION_TAG.ALLY )
end

function Faction:AddEnemy( other )
	assert( is_instance( other, Faction ))
	self.faction:AddTag( other.faction, FACTION_TAG.ENEMY )
end

-- Assign our faction to agent's.
function Faction:AssignFaction( agent )
	local faction = agent:GetAspect( Aspect.Faction )
	if faction then
		faction.faction = self.faction
	else
		faction = agent:GainAspect( Aspect.Faction( self.faction ))
	end

	return faction -- return agent's Aspect.Faction
end
