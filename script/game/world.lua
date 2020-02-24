local World = class( "World", WorldBase )

function World:init()
	WorldBase.init( self )

	self.datetime = DATETIME_START
	self.locations = {}
	self.agents = {}
	self.stats = {}
	self.relationships = {}
	self.factions = {}

	-- self.rng = love.math.newRandomGenerator( 3418323524, 20529293 )
	self.rng = love.math.newRandomGenerator( 5235235, 120912 )
	print( "WorldGen seeds:", self.rng:getSeed() )

	self.limbo = Location()
	self.limbo:SetDetails( "Limbo", "Implementation room." )
	self:SpawnLocation( self.limbo )

	self.history = self:GainAspect( Aspect.History() )
	self.history:SaveToFile( "log.txt" )
	self.map = self:GainAspect( Aspect.TileMap() )

	self.names = self:GainAspect( Aspect.NamePool( "data/names.txt" ) )
	self.adjectives = Aspect.NamePool( "data/adjectives.txt" )
	self.nouns = Aspect.NamePool( "data/nouns.txt" )
	self.city_names = self:GainAspect( Aspect.CityNamePool( "data/cities.txt" ))
end

function World:Log( fmt, ... )
	self.history:Log( loc.format( "{1}: {2}", Calendar.FormatTime( self.datetime ), fmt ), ... )
end

function World:Start()
	self:Log( "World started!" )
	self:BroadcastEvent( WORLD_EVENT.START, self )
end

function World:CreateFaction( name )
	local faction = FactionData( name )
	for i, f in ipairs( self.factions ) do
		if self:Random() < 0.8 then
			f:AddTag( faction, FACTION_TAG.ENEMY )
			faction:AddTag( f, FACTION_TAG.ENEMY )
		end
	end

	table.insert( self.factions, faction )
	return faction
end

function World:Factions()
	return ipairs( self.factions )
end

function World:SpawnLocation( location )
	self:SpawnEntity( location )
end

function World:GetLocationAt( x, y )
	return self.map:LookupGrid( x, y )
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

function World:DoAsync( fn,... )
	local coro = coroutine.create( fn )

	local ok, result = coroutine.resume( coro, self, ... )
	if not ok then
		error( tostring(result) .. "\n" .. tostring(debug.traceback( coro )))
	end
end

function World:SpawnEntity( ent, location )
	WorldBase.SpawnEntity( self, ent )

	if location then
		ent:WarpToLocation( location )
	end

	if is_instance( ent, Agent ) then
		if not ent.location and not location then
			ent:WarpToLocation( ent:GetHome() or self.limbo )
		end

		table.insert( self.agents, ent )

		if ent:IsPlayer() then
			assert( self.player == nil )
			self.player = ent
			self.puppet = ent
		end

	elseif is_instance( ent, Location ) then
		table.insert( self.locations, ent )
	end

	return ent
end

function World:SpawnAgent( agent, location )
	assert( is_instance( agent, Agent ))
	return self:SpawnEntity( agent, location )
end

function World:RequireAgent( ctor, pred )
	local agent
	
	if pred then
		local t = ObtainWorkTable()
		for i, agent in ipairs( self.agents ) do
			if pred( agent ) then
				table.insert( t, agent )
			end
		end
		agent = self:ArrayPick( t )
		ReleaseWorkTable( t )
	end

	if agent == nil then
		agent = ctor( self )
		assert( agent:IsSpawned(), "Not spawned" )
	end

	return agent

end

function World:Random( a, b )
	if a == nil and b == nil then
		return self.rng:random()
	elseif b == nil then
		return self.rng:random( a )
	else
		return self.rng:random( a, b )
	end
end

function World:ArrayPick( t )
	return t[ self:Random( #t ) ]
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
	assert( agent == nil or is_instance( agent, Agent ))

	self.puppet = agent
	self:RefreshTimeSpeed()

	if self:IsPaused( PAUSE_TYPE.FOCUS_MODE ) ~= is_instance( agent:GetFocus(), Agent ) then
		self:TogglePause( PAUSE_TYPE.FOCUS_MODE) 
	end
end

function World:RefreshTimeSpeed()
	self.puppet_time_speed = self.puppet:CalculateTimeSpeed()
end

function World:CalculateTimeElapsed( dt )
	return (self.puppet_time_speed or 1.0) * WorldBase.CalculateTimeElapsed( self, dt )
end

function World:OnUpdateWorld( dt, world_dt )
	for i, stat in ipairs( self.stats ) do
		stat:Regen( world_dt )
	end
end
