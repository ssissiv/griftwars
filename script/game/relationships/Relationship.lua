local Relationship = class( "Relationship", Entity )

function Relationship:init()
	Entity.init( self )

	self.agents = {}
end

function Relationship:OnSpawn( world )
	Entity.OnSpawn( self, world )
	for i, agent in ipairs( self.agents ) do
		agent:_AddRelationship( self )
	end
end

function Relationship:HasAgent( agent )
	return table.contains( self.agents, agent )
end

function Relationship:Agents()
	return pairs( self.agents )
end

function Relationship:AddAgent( agent )
	if self.world then
		agent:_AddRelationship( self )
	end
	table.insert( self.agents, agent )
	return agent
end

function Relationship:CheckPrivacy( target, flag )
	return false
end

function Relationship:IsKnownBy( agent )
	return false
end

function Relationship:AddKnownBy( agent )
	
end
