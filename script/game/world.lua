local World = class( "World", WorldBase )

function World:init()
	WorldBase.init( self )

	self.datetime = DATETIME_START
	self.locations = {}
	self.agents = {}
	self.stats = {}
	self.relationships = {}

	self.rng = self:GainAspect( Aspect.Rng( 12345, 54321 ) )

	print( "WorldGen seeds:", self.rng:GetSeed() )

	-- self.limbo = Location()
	-- self.limbo:SetDetails( "Limbo", "Implementation room." )
	-- self:SpawnLocation( self.limbo )

	self.history = self:GainAspect( Aspect.History() )
	self.history:SaveToFile( "history.txt" )
	self.map = self:GainAspect( Aspect.TileMap() )
	self.acc = self:GainAspect( Aspect.ScalarCalculator() )

	self.names = self:GainAspect( Aspect.NamePool( "data/names.txt" ))
	self.adjectives = self:GainAspect( Aspect.NamePool( "data/adjectives.txt" ))
	self.nouns = self:GainAspect( Aspect.NamePool( "data/nouns.txt" ))
	self.city_names = self:GainAspect( Aspect.CityNamePool( "data/cities.txt" ))
end

function World:Log( fmt, ... )
	self.history:Log( loc.format( "{1}: {2}", Calendar.FormatDateTime( self.datetime ), fmt ), ... )
end

function World:Start()
	self:Log( "World started!" )
	self:BroadcastEvent( WORLD_EVENT.START, self )
end

function World:GetWorldMap()
	return self.map
end

function World:SpawnLocation( location )
	self:SpawnEntity( location )
end

function World:GetLocationAt( x, y, z )
	return self.map:LookupTile( x, y, z )
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

function World:CollectIntel( quality )
	return self.acc:CalculateValue( CALC_EVENT.COLLECT_INTEL, {}, quality )
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
		if not ent.location and ent:GetHome() then
			ent:WarpToLocation( ent:GetHome() )
		end

		table.insert( self.agents, ent )

		if ent:IsPlayer() then
			assert( self.player == nil )
			self.player = ent
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

function World:RollDice( num, size, bonus )
	return self.rng:RollDice( num, size, bonus )
end

function World:Random( a, b )
	return self.rng:Random( a, b )
end

function World:RandomGauss( mean, stddev, min_clamp, max_clamp )
	return self.rng:RandomGauss( mean, stddev, min_clamp, max_clamp )
end

function World:ArrayPick( t )
	return self.rng:ArrayPick( t )
end

function World:WeightedPick( options )
	return self.rng:WeightedPick( options )
end

function World:Shuffle( t, start_index, end_index )
	return self.rng:Shuffle( t, start_index, end_index )
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

	if self.puppet then
		self.puppet:LoseAspect( Aspect.Puppet )
	end

	self.puppet = agent

	if agent then
		agent:GainAspect( Aspect.Puppet() )
	end

	self:BroadcastEvent( WORLD_EVENT.PUPPET_CHANGED, agent )
	self:RefreshTimeSpeed()

	if self:IsPaused( PAUSE_TYPE.FOCUS_MODE ) ~= is_instance( agent:GetFocus(), Agent ) then
		self:TogglePause( PAUSE_TYPE.FOCUS_MODE) 
	end
end

function World:RefreshTimeSpeed()
	-- Need to PAUSE while the puppet is idle (not doing verbs)
	-- This needs to be some kind of 'autoplay' option, so you can switch to anyone but still have them carry out behaviour
	--if not self.puppet:IsBusy() and self.puppet == self.player then
	if not self.puppet:IsBusy() then
		if not self:IsPaused( PAUSE_TYPE.IDLE ) then
			self:TogglePause( PAUSE_TYPE.IDLE )
		end
	else
		if self:IsPaused( PAUSE_TYPE.IDLE ) then
			self:TogglePause( PAUSE_TYPE.IDLE )
		end
	end
end

function World:CalculateTimeElapsed( dt )
	if self.puppet and self.puppet == self.player then
		dt = self.puppet:CalculateTimeElapsed( dt )
	end

	return WorldBase.CalculateTimeElapsed( self, dt )
end

function World:OnUpdateWorld( dt, world_dt )
	for i, stat in ipairs( self.stats ) do
		stat:Regen( world_dt )
	end
end
