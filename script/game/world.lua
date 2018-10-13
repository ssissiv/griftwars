local World = class( "World", WorldBase )

function World:init()
	WorldBase.init( self )

	self.locations = {}
	self.agents = {}
end

function World:AddLocation( location )
	table.insert( self.locations, location )
end

function World:AllLocations()
	return ipairs( self.locations )
end

function World:AddAgent( agent )
	table.insert( self.agents, agent )

	if agent:HasFlag( Agent.FLAGS.PLAYER ) then
		assert( self.player == nil )
		self.player = agent
	end
end

function World:AllAgents()
	return ipairs( self.agents )
end

function World:MoveAgent( agent, to )
	local from = agent:GetLocation()
	if from then
		agent:ExitLocation()
		from:RemoveAgent( agent )
	end

	if to then
		agent:EnterLocation( to )
		to:AddAgent( agent )
	end
end

function World:GetPlayer()
	return self.player
end


