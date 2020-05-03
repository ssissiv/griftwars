local FLAGS = MakeEnum{
	"PLAYER"
}

local Agent = class( "Agent", Entity )
Agent.FLAGS = FLAGS

function Agent:init()
	Entity.init( self )
	self.prestige = 1
	self.species = SPECIES.NONE
	self.flags = {}
	self.stats = {}
	self.sense_log = {} -- array of strings
	self.potential_verbs = {}
	self.inventory = Inventory( self )
	self:GainAspect( Aspect.Memory() )

	self.viz = AgentViz()
	self.mental_state = MSTATE.ALERT

	self:CreateStat( STAT.FATIGUE, 0, 100 ):DeltaRegen( 100 / (2 * ONE_DAY) )

	self:GainAspect( Aspect.HealthValue( 6, 6 ))
	self:CreateStat( STAT.CHARISMA, 1, 1 )
end

function Agent:OnSpawn( world )
	Entity.OnSpawn( self, world )

	if self.species == SPECIES.NONE then
		self.species = world:ArrayPick( SPECIES_ARRAY )
	end

	if self.name == nil and SPECIES_PROPS[ self.species ].name_pool then
		self.name = world:GetAspect( Aspect.NamePool ):PickName()
	end
	
	if self.gender == nil then
		self.gender = math.random() < 0.5 and GENDER.MALE or GENDER.FEMALE
	end
	
	if self.OnAgentEvent then
		self:ListenForAny( self, self.OnAgentEvent )
	end
	
	world:Log( "Spawned: {1}", self )
end

function Agent:OnDespawn()
	self.world:Log( "Despawned: {1}", self )

	if self.name then
		self.world.names:AddName( self.name )
	end

	self:WarpToNowhere()

	if self.verbs then
		for i = #self.verbs, 1, -1 do
			local verb = self.verbs[i]
			verb:Cancel()
		end
	end

	Entity.OnDespawn( self )
end


function Agent:SetFlags( ... )
	for i, flag in ipairs({...}) do
		self.flags[ flag ] = true
	end
end

function Agent:SetMentalState( state )
	if state ~= self.mental_state then
		assert( IsEnum( state, MSTATE ))
		self.mental_state = state
		self:CancelInvalidVerbs()
	end
end

function Agent:GetMapChar()
	return self.MAP_CHAR
end

function Agent:IsAlert()
	return self.mental_state == MSTATE.ALERT
end

function Agent:HasFlag( flag )
	return self.flags[ flag ] == true
end

function Agent:GetName()
	return self.name or self.species or "No Name"
end

function Agent:GetTitle()
end

function Agent:GetDesc()
	return self.desc or "No Desc"
end

function Agent:IsPlayer()
	return self:HasAspect( Aspect.Player )
end

function Agent:GetPlayer()
	return self:GetAspect( Aspect.Player )
end

function Agent:IsPuppet()
	return self.world:GetPuppet() == self
end

function Agent:GetShortDesc( viewer )
	local desc
	if self.verbs then
		for i, verb in ipairs( self.verbs ) do
			if not verb:IsCancelled() then
				desc = verb:GetShortDesc( viewer )
				if desc ~= nil then
					break
				end
			end
		end
	end

	if desc == nil then
		if self.mental_state ~= MSTATE.ALERT then
			desc = loc.format( "{1.Id} is here. [{2}]", self:LocTable( viewer ), self.mental_state )
		else
			desc = loc.format( "{1.Id} is here.", self:LocTable( viewer ) )
		end
	end

	if self.focus == self.world:GetPuppet() then
		desc = desc .. loc.format( " {1.HeShe} is looking at you.", self:LocTable( viewer ) )
	end

	local title = self:GetTitle()
	if title then
		desc = desc .. loc.format( "({1})", title )
	end

	return desc
end

function Agent:GetLeader()
	return self.leader
end

function Agent:SetLeader( leader )
	assert( is_instance( leader, Agent ))
	assert( leader:GetAspect( Trait.Leader ))
	self.leader = leader
end

function Agent:RegenVerbs( id )
	if id then
		if self.potential_verbs[ id ] then
			self.potential_verbs[ id ]:SetDirty()
		end
	else
		for id, verbs in pairs( self.potential_verbs ) do
			verbs:SetDirty()
		end
	end
end

function Agent:CollectPotentialVerbs( id, ... )
	id = id or "room"
	local verbs = self.potential_verbs[ id ]
	if verbs == nil then
		verbs = VerbContainer( id )
		self.potential_verbs[ id ] = verbs
	end

	verbs:CollectVerbs( self, ... )

	return verbs
end

function Agent:GetPotentialVerbs( id, ... )
	return self:CollectPotentialVerbs( id, ... )
end

function Agent:PotentialVerbs( id, ... )
	local verbs = self:CollectPotentialVerbs( id, ... )
	return verbs:Verbs()
end

function Agent:SetDetails( name, desc, gender )
	if name then
		self.name = name
	end
	if desc then
		self.desc = desc
	end
	if gender then
		self.gender = gender
	end
end

function Agent:RegenerateLocTable( viewer )
	if self.loc_table and self.loc_table.viewer == viewer then
		self.loc_table = self:GenerateLocTable( viewer )
	end
end

function Agent:LocTable( viewer )
	if viewer == nil and self.world then
		viewer = self.world:GetPuppet()
	end

	if self.loc_table == nil or self.loc_table.viewer ~= viewer  then
		self.loc_table = self:GenerateLocTable( viewer )
	end
	return self.loc_table
end

function Agent:GenerateLocTable( viewer )
	local t = { viewer = viewer }
	if self.gender == GENDER.MALE then
		t.gender = "male"
		t.himher = "him"
		t.hisher = "his"
		t.heshe = "he"
		t.HeShe = "He"

	elseif self.gender == GENDER.FEMALE then
		t.gender = "female"
		t.himher = "her"
		t.hisher = "her"
		t.heshe = "she"
		t.HeShe = "She"

	else
		t.himher = "it"
		t.hisher = "its"
		t.heshe = "it"
		t.HeShe = "It"
	end

	if self.name then
		if viewer == nil then
			t.id = loc.format( "[[{1}]]", self.name )
		elseif viewer == self or viewer:CheckPrivacy( self, PRIVACY.ID ) then
			t.id = loc.format( "[{1}]", self.name )
		else
			t.id = loc.format( "[{1} {2}]", self.species, self._classname )
		end
	else
		t.id = loc.format( "[{1}]", self.species )
	end
	t.Id = t.id

	t.name = self:GetName()

	return t
end

function Agent:GetPrestige()
	return self.prestige
end

function Agent:GetInventory()
	return self.inventory
end

function Agent:GetMemory()
	return self.memory -- Assigned by Aspect.Memory when attained.
end

function Agent:IsAcquainted( agent )
	return self:GetAffinity( agent ) ~= AFFINITY.STRANGER
end

function Agent:Acquaint( agent )
	local affinity = self.affinities and self.affinities[ agent ]
	if affinity == nil then
		affinity = Relationship.Affinity( self, agent )
		self.world:SpawnRelationship( affinity )
	end

	if affinity:GetAffinity() == AFFINITY.STRANGER then
		affinity:SetAffinity( AFFINITY.KNOWN )

		self:GainXP( 10 )

		return true
	else
		return false
	end
end

function Agent:CanSee( obj )
	if self.location and self.location == obj:GetLocation() then
		return true
	end

	return false
end

function Agent:HasEngram( pred, ... )
	if self.memory then
		return self.memory:HasEngram( pred, ... )
	end

	return false
end

function Agent:CheckPrivacy( obj, pr_flags )
	if self.memory then
		if self.memory:CheckPrivacy( obj, pr_flags ) then
			return true
		end
	end
	if self.relationships then
		for i, r in ipairs( self.relationships ) do
			if r:CheckPrivacy( self, obj, pr_flags ) then
				return true
			end
		end
	end

	return false
end

function Agent:_AddRelationship( r )
	if self.relationships == nil then
		self.relationships = {}
	end
	table.insert( self.relationships, r )
	
	if is_instance( r, Relationship.Affinity ) then
		if self.affinities == nil then
			self.affinities = {}
		end
		self.affinities[ r:GetOther( self ) ] = r
	end

	for i, agent in r:Agents() do
		agent:RegenerateLocTable( self )
	end
	self:RegenVerbs()
end

function Agent:CountRelationships()
	return self.relationships and #self.relationships or 0
end

function Agent:Relationships()
	return ipairs( self.relationships or table.empty )
end

function Agent:IsFriends( other )
	if self.affinities and self.affinities[ other ] then
		return self.affinities[ other ]:GetAffinity() == AFFINITY.FRIEND
	end

	return false
end

function Agent:GetMaxFriends()
	return self:GetStatValue( STAT.CHARISMA ) or 0
end

function Agent:CountAffinities( affinity )
	local count = 0
	if self.affinities then
		for agent, rel in pairs( self.affinities ) do
			if rel:GetAffinity() == affinity then
				count = count + 1
			end
		end
	end
	return count
end

function Agent:Befriend( other )
	local affinity = self.affinities and self.affinities[ other ]
	if affinity == nil then
		self.world:SpawnRelationship( Relationship.Affinity( self, other, AFFINITY.FRIEND ))
	else
		affinity:SetAffinity( AFFINITY.FRIEND )
	end
end

function Agent:Unfriend( other )
	local affinity = self.affinities[ other ]
	if affinity == nil then
		self.world:SpawnRelationship( Relationship.Affinity( self, other, AFFINITY.UNFRIEND ))
	else
		affinity:SetAffinity( AFFINITY.UNFRIEND )
	end
end

function Agent:SetCoordinate( x, y )
	if x ~= self.x or y ~= self.y then
		self.x, self.y = x, y
		self:BroadcastEvent( AGENT_EVENT.TILE_CHANGED, x, y )
	end
end

function Agent:GetCoordinate()
	return self.x, self.y
end

function Agent:IsAdjacent( obj )
	local x, y = AccessCoordinate( obj )
	return x and y and IsAdjacentCoordinate( x, y, self.x, self.y )
end

function Agent:GetTile()
	if self.location then
		return self.location:GetTileAt( self.x, self.y )
	end
end

function Agent:Walk( exit )
	local x, y = OffsetExit( self.x, self.y, exit )
	local tile = self.location:GetTileAt( x, y )
	if tile and tile:IsPassable( self ) then
		local current_tile = self.location:GetTileAt( self.x, self.y )
		current_tile:RemoveEntity (self )

		self.x, self.y = x, y

		tile:AddEntity( self )

		self:BroadcastEvent( AGENT_EVENT.TILE_CHANGED, x, y )
	end
end

local function WarpToLocation( self, location, x, y )
	local prev_location = self.location
	if self.location then
		self:SetFocus( nil )
		self.location:RemoveAgent( self )
		self.location = nil
	end

	self:CancelInvalidVerbs()
	self:RegenVerbs()

	if location then
		self.location = location
		self:SetCoordinate( x, y )
		location:AddAgent( self )
	end

	for i, aspect in self:Aspects() do
		if aspect.OnLocationChanged then
			aspect:OnLocationChanged( prev_location, location )
		end
	end

	self:BroadcastEvent( AGENT_EVENT.LOCATION_CHANGED, location, prev_location )
end

function Agent:WarpToNowhere()
	WarpToLocation( self )
end

function Agent:WarpToLocation( location, x, y )
	assert( is_instance( location, Location ), tostring(location))
	WarpToLocation( self, location, x, y )
end

function Agent:WarpToAgent( agent )
	self:WarpToLocation( agent:GetLocation(), agent:GetCoordinate() )
end

function Agent:GetLocation()
	return self.location
end

function Agent:IsBusy( flags )
	if self.verbs then
		for i, verb in ipairs( self.verbs ) do
			if verb:HasBusyFlag( flags ) then
				return true, verb
			end
		end
	end
	return false
end

function Agent:AssertNotBusy()
	if self:IsBusy() then
		print( self, " is busy: ", tostr(self.verbs, 2))
		error()
	end
end

function Agent:IsDoing( verb )
	for i, v in ipairs( self.verbs or table.empty ) do
		if v == verb then
			return true
		end
	end
	return false
end

function Agent:AttemptVerb( verb_class, obj )
	self:RegenVerbs( "room" )
	local verbs = self:GetPotentialVerbs( "room", obj )
	verbs:SortByDistanceTo( self:GetCoordinate() )
	local verb = verbs:FindVerbClass( verb_class )
	if verb then
		self:DoVerbAsync( verb )
	end
end

function Agent:DoVerbAsync( verb, ... )
	if not verb:CanDo( self, ... ) then
		print( "No can do!", self, verb, ... )
		return
	end

	local coro = coroutine.create( verb.DoVerb )
	local ok, result = coroutine.resume( coro, verb, self, ... )
	if not ok then
		error( tostring(result) .. "\n" .. tostring(debug.traceback( coro )))
	end
end

function Agent:_AddVerb( verb )
	if self.verbs == nil then
		self.verbs = {}
	end

	assert( not self:IsDoing( verb ))

	table.insert( self.verbs, verb )
	assert( #self.verbs < 10, "Too many verbs: " ..tostring(self) )

	if self:IsPuppet() then
		self.world:RefreshTimeSpeed()
	end

	return true
end

function Agent:_RemoveVerb( verb )
	for i, v in ipairs( self.verbs ) do
		if verb == v then
			table.remove( self.verbs, i )
			if #self.verbs == 0 then
				self.verbs = nil
			end

			self:BroadcastEvent( AGENT_EVENT.VERB_UNASSIGNED, verb )

			if self:IsPuppet() then
				self.world:RefreshTimeSpeed()
			end
			return
		end
	end
	error( "No verb to remove: " .. tostring(verb))
end

function Agent:Verbs()
	return ipairs( self.verbs or table.empty )
end

function Agent:CancelInvalidVerbs()
	if self.verbs then
		for i = #self.verbs, 1, -1 do
			local verb = self.verbs[i]
			if not verb:CanInteract( self ) then
				verb:Cancel()
			end
			if self.verbs == nil then
				break
			end
		end
	end
end

function Agent:CalculateTimeSpeed()
	local rate = 1.0
	if self.verbs then
		for i, verb in ipairs( self.verbs ) do
			rate = math.max( verb:CalculateTimeSpeed() or rate, rate )
		end
	end
	return rate
end

function Agent:CreateStat( stat, value, max_value )
	assert( self:GetAspect( stat ) == nil )

	local aspect = Aspect.StatValue( stat, value, max_value )
	self:GainAspect( aspect )

	return aspect
end

function Agent:DeltaStat( stat, delta )
	local aspect = self.stats[ stat ]
	if aspect then
		aspect:DeltaValue( delta )
		-- Msg:Echo( self, "You gain {1} {2}!", delta, stat )
	end
end

function Agent:DeltaHealth( delta )
	self:DeltaStat( STAT.HEALTH, delta )
end

function Agent:GetHealth()
	return self:GetStatValue( STAT.HEALTH )
end

function Agent:Kill()
	if self:IsPuppet() then
		self.world:TogglePause( PAUSE_TYPE.GAME_OVER )
	end

	print( self, self:GetAspect(  Aspect.Faction ), "died!" )

	Msg:ActToRoom( "{1.Id} dies!", self )
	Msg:Echo( self, "You die!" )
	self.world:DespawnEntity( self )

	self:GainAspect( Aspect.Killed() )
end

function Agent:IsDead()
	return self:HasAspect( Aspect.Killed() )
end

function Agent:GetStatValue( stat )
	if self.stats[ stat ] then
		return self.stats[ stat ]:GetValue()
	end
end

function Agent:GetStat( stat )
	return self.stats[ stat ]
end

function Agent:Stats()
	return pairs( self.stats )
end

function Agent:CanSee( obj )
	return true
end

function Agent:Sense( txt )
	table.insert( self.sense_log, { desc = txt, sensor_type = SENSOR.VISION, when = self.world:GetDateTime() } )
end

function Agent:Echo( txt )
	table.insert( self.sense_log, { desc = txt, sensor_type = SENSOR.ECHO, when = self.world:GetDateTime() } )
end

function Agent:Senses()
	return ipairs( self.sense_log )
end

function Agent:GetSenses()
	return self.sense_log
end

function Agent:SetFocus( focus )
	if focus == self.focus then
		return
	end
	
	local prev_focus = self.focus
	self.focus = focus

	if prev_focus then
		local LOSE_FOCUS =
		{
			"You turn your attention away from {2.id}",
			"{1.Id} turns away from you.",
		}
		Msg:Action( LOSE_FOCUS, self, prev_focus )

		if prev_focus.OnLostFocus then
			prev_focus:OnLostFocus( self )
		end

		if self:IsPuppet() and is_instance( prev_focus, Agent ) then
			self.world:TogglePause( PAUSE_TYPE.FOCUS_MODE) 
		end
	end

	if focus then
		local GAIN_FOCUS =
		{
			"You turn your attention to {2.id}",
			"{1.Id} turns their attention to you.",
		}
		Msg:Action( GAIN_FOCUS, self, focus )

		if focus.OnReceivedFocus then
			focus:OnReceivedFocus( self )
		end

		if self:IsPuppet() and is_instance( focus, Agent ) then
			self.world:TogglePause( PAUSE_TYPE.FOCUS_MODE) 
		end
	end

	-- Focus probably changes verb eligibility.
	self:CancelInvalidVerbs()
	self:RegenVerbs()

	-- print( "CHANGE FOCUS", self, self.focus )
	self:BroadcastEvent( AGENT_EVENT.FOCUS_CHANGED, prev_focus, self.focus )
end

function Agent:GetFocus()
	return self.focus
end

function Agent:OnLostFocus( other )
	if self.focus == other then
		self:SetFocus( nil )
	end
end

function Agent:OnReceivedFocus( other )
	local noticed = not self:IsBusy()
	if noticed then
		if self.focus ~= other then
			local GREETING =
			{
				"You notice {2.id} looking at you.",
				nil,
				"{1.id} notices you looking at them.",
			}
			Msg:Action( GREETING, self, other )

			self:SetFocus( other )
		end
	end
	self:RegenVerbs()
end

function Agent:GetAffinity( other )
	local affinity = self.affinities and self.affinities[ other ]
	if affinity then
		return affinity:GetAffinity()
	end
end

function Agent:DeltaTrust( trust )
	local other = self.world:GetPlayer()
	local affinity = self.affinities and self.affinities[ other ]
	if affinity == nil then
		affinity = Relationship.Affinity( self, other )
		self.world:SpawnRelationship( affinity )
	end

	if affinity then
		affinity:DeltaTrust( trust )
		Msg:Echo( other, "{1.Id}'s trust with you increases! ({2%+d})", self:LocTable( other ), trust )

	end
end


function Agent:GainXP( xp )
	if self.stats[ STAT.XP ] then
		self:DeltaStat( STAT.XP, xp )
	end
end

function Agent:AssignXP( xp, stat )
	if self.stats[ STAT.XP ] then
		self:DeltaStat( STAT.XP, -xp )
	end
	if self.stats[ stat ] then
		self.stats[ stat ]:GainXP( xp )
	end
end

function Agent.GetAgentOwner( obj )
	while obj do
		if is_instance( obj, Agent ) then
			return obj
		else
			obj = obj.owner
		end
	end
end

function Agent:RenderMapTile( screen, tile, x1, y1, x2, y2 )
	love.graphics.setFont( assets.FONTS.MAP_TILE )
	local ch, clr = self:GetMapChar()
	love.graphics.setColor( table.unpack( clr or constants.colours.WHITE ))
	local scale = DEFAULT_ZOOM / screen.camera:GetZoom()
	love.graphics.print( ch or "?", x1 + (x2-x1)/6, y1, 0, 1.4 * scale, 1 * scale )
end

function Agent:__tostring()
	return string.format( "[%s%s%s]",
		self:IsPlayer() and "@" or "",
		self:GetName(),
		self.location == nil and "*" or "" )
end


