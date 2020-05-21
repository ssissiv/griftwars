local Faction = class( "Faction", Entity )

function Faction:init( name )
	self.name = name
	self.tags = {}
	self.roles = {}
end

function Faction:GetFactionName()
	return self.name
end

function Faction:AddFactionMember( agent, role )
	if self.roles[ role ] == nil then
		self.roles[ role ] = {}
	end
	table.insert( self.roles[ role ], agent )
	agent:GainAspect( Aspect.FactionMember( self, role ))
end

function Faction:GetAgentsByRole( role )
	return self.roles[ role ] or table.empty
end

function Faction:HasTag( faction, tag )
	assert( IsEnum( tag, FACTION_TAG ))
	local t = self.tags[ faction ]
	return t and table.contains( t, tag )
end

function Faction:AddTag( faction, tag )
	assert( IsEnum( tag, FACTION_TAG ))
	local t = self:AffirmFaction( faction )
	table.insert_unique( t, tag )
end

function Faction:AffirmFaction( faction )
	local t = self.tags[ faction ]
	if t == nil then
		t = {}
		self.tags[ faction ] = t
	end
	return t
end

function Faction:VerifyAgentLocations()
	for role, agents in pairs( self.roles ) do
		for i, agent in ipairs( agents ) do
			if agent:GetLocation() == nil then
				print( "IN LIMBO:", self.name, role, i, agent )
			end
		end
	end
end

function Faction:__tostring()
	return string.format( "[Faction: %s]", self.name )
end
