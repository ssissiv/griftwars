local World = class( "World", WorldBase )

function World:init()
	WorldBase.init( self )

	self.datetime = DATETIME_START
	self.locations = {}
	self.agents = {}
end

function World:SpawnLocation( location )
	location:OnSpawn( self )
	table.insert( self.locations, location )
end

function World:AllLocations()
	return ipairs( self.locations )
end

function World:SpawnAgent( agent )
	agent:OnSpawn( self )
	table.insert( self.agents, agent )

	if agent:HasFlag( Agent.FLAGS.PLAYER ) then
		assert( self.player == nil )
		self.player = agent
		self.puppet = agent
	end
end

function World:AllAgents()
	return ipairs( self.agents )
end

function World:GetPlayer()
	return self.player
end

function World:GetPuppet()
	return self.puppet
end

function World:SetPuppet( agent )
	assert( is_instance( agent, Agent ))
	self.puppet = agent
end

function World:GetDateTime()
	return self.datetime
end
