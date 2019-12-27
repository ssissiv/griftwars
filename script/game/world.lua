local World = class( "World", WorldBase )

function World:init()
	WorldBase.init( self )

	self.datetime = DATETIME_START
	self.locations = {}
	self.agents = {}
	self.stats = {}
	self.relationships = {}

	self.limbo = Location()
	self.limbo:SetDetails( "Limbo", "Implementation room." )
	self:SpawnLocation( self.limbo )

	self.history = self:GainAspect( Aspect.History() )
	self.names = self:GainAspect( Aspect.NamePool( "data/names.txt" ) )
	self.adjectives = Aspect.NamePool( "data/adjectives.txt" )
	self.nouns = Aspect.NamePool( "data/nouns.txt" )
end

function World:Log( fmt, ... )
	self.history:Log( loc.format( "{1}: {2}", Calendar.FormatTime( self.datetime ), fmt ), ... )
end

function World:Start()
	self:Log( "World started!" )
	self:BroadcastEvent( WORLD_EVENT.START, self )
end

function World:SpawnLocation( location )
	self:SpawnEntity( location )
	table.insert( self.locations, location )
end

function World:AllLocations()
	return ipairs( self.locations )
end

function World:RegisterStatValue( stat )
	table.insert( self.stats, stat )
end

function World:UnregisterStatValue( stat )
	table.arrayremove( self.stats, stat )
end

function World:GetLimbo()
	return self.limbo
end

function World:SpawnAgent( agent, location )
	self:SpawnEntity( agent )

	if location then
		agent:WarpToLocation( location )
	elseif not agent.location then
		agent:WarpToLocation( agent:GetHome() or self.limbo )
	end

	table.insert( self.agents, agent )

	if agent:IsPlayer() then
		assert( self.player == nil )
		self.player = agent
		self.puppet = agent
	end

	return agent
end

function World:AllAgents()
	return ipairs( self.agents )
end

function World:SpawnRelationship( rel )
	assert( is_instance( rel, Relationship ))
	self:SpawnEntity( rel )

	table.insert( self.relationships, rel )
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
	self:RefreshTimeSpeed()

	if self:IsPaused( PAUSE_TYPE.FOCUS_MODE ) ~= (agent:GetFocus() ~= nil) then
		self:TogglePause( PAUSE_TYPE.FOCUS_MODE) 
	end
end

function World:RefreshTimeSpeed()
	self.puppet_time_speed = self.puppet:CalculateTimeSpeed()
end

function World:CalculateTimeElapsed( dt )
	return dt * (self.puppet_time_speed or 1.0)
end

function World:OnUpdateWorld( dt, world_dt )
	for i, stat in ipairs( self.stats ) do
		stat:Regen( world_dt )
	end
end
