local Faction = class( "Faction", Entity )

function Faction:init( name )
	self.name = name
	self.tags = {}
	self.roles = {} -- Sorted array of FACTION_ROLE
	self.members = {} -- Map of FACTION_ROLE -> { agent_list }
end

function Faction:IsLawful()
	return self.lawful == true
end

function Faction:GetFactionName()
	return self.name
end

function Faction:AddFactionMember( agent, role, role_title )
	table.insert_unique( self.roles, role )
	if self.members[ role ] == nil then
		self.members[ role ] = {}
	end
	table.insert( self.members[ role ], agent )
	agent:GainAspect( Aspect.FactionMember( self, role, role_title ))
end

function Faction:GetAgentsByRole( role )
	return self.members[ role ] or table.empty
end

function Faction:GetSuperiorsByRole( role )
	local idx = table.find( self.roles, role )
	if idx and idx > 1 then
		local role = self.roles[ idx - 1 ]
		return self.members[ role ]
	end

	return table.empty
end

function Faction:GetSubordinatesByRole( role )
	local idx = table.find( self.roles, role )
	if idx then
		for i = idx + 1, #self.roles do
			local role = self.roles[ i ]
			return self.members[ role ] or table.empty
		end
	end

	return table.empty
end

function Faction:HasTagForFaction( faction, tag )
	assert( IsEnum( tag, FACTION_TAG ))
	local t = self.tags[ faction ]
	return t and table.contains( t, tag ) or false
end

function Faction:AddTagForFaction( faction, tag )
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
	for role, agents in pairs( self.members ) do
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
