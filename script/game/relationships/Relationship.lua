local Relationship = class( "Relationship", Entity )

function Relationship:init()
	Entity.init( self )

	self:GainAspect( Interaction.LearnRelationship() )

	self.agents = {}
end


function Relationship:HasAgent( agent )
	return table.contains( self.agents, agent )
end

function Relationship:AddAgent( agent )
	agent:_AddRelationship( self )
	table.insert( self.agents, agent )
	return agent
end

function Relationship:IsKnownBy( agent )
	return false
end

function Relationship:AddKnownBy( agent )
	
end
