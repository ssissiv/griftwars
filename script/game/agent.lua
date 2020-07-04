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
	self.inventory = self:GainAspect( Aspect.Inventory() )
	self:GainAspect( Aspect.Memory() )
	self.acc = self:GainAspect( Aspect.ScalarCalculator() )

	self.viz = AgentViz()
	self.mental_state = MSTATE.ALERT
end

function Agent:OnSpawn( world )
	Entity.OnSpawn( self, world )

	self.rng = self:GainAspect( Aspect.Rng())

	if self.species == SPECIES.NONE then
		self.species = world:ArrayPick( SPECIES_ARRAY )
	end

	if self.name == nil and SPECIES_PROPS[ self.species ].name_pool then
		self.name = world:GetAspect( Aspect.NamePool ):PickName()
	end
	
	if self.gender == nil then
		self.gender = GENDER.NEUTRAL
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
			if self.verbs == nil then
				break
			end
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

function Agent:IsSleeping()
	return self.mental_state == MSTATE.SLEEPING
end

function Agent:IsAlert()
	return self.mental_state == MSTATE.ALERT
end

function Agent:HasFlag( flag )
	return self.flags[ flag ] == true
end

function Agent:GetName( viewer )
	return self.name
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

function Agent:GetSpeciesProps()
	return SPECIES_PROPS[ self.species ]
end

function Agent:GetShortDesc( viewer )
	return self:LocTable( viewer ).desc
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

	t.name = self.name

	-- Unfamiliar description: when the target is unknown
	local unfamiliar_desc
	if self.unfamiliar_desc then
		unfamiliar_desc = loc.format( "{1}", self.unfamiliar_desc )
	else
		unfamiliar_desc = loc.format( "{1} {2}", SPECIES_PROPS[ self.species ].name, self._classname )
	end

	t.udesc = unfamiliar_desc
	t.Udesc = loc.cap( t.udesc )


	if self.name == nil then
		-- Things with no name are simply their unfamiliar description.
		t.desc = unfamiliar_desc

	else
		-- Identified description: The unfamiliar description identified as the target if it is known
		if viewer == nil then
			t.desc = loc.format( "[{1}, {2}]", self.name, unfamiliar_desc )
		elseif viewer == nil or viewer == self or viewer:CheckPrivacy( self, PRIVACY.ID ) then
			t.desc = loc.format( "[{1}, {2}]", self.name, unfamiliar_desc )
		else
			t.desc = loc.format( "[{1}]", unfamiliar_desc )
		end
	end

	t.Desc = loc.cap( t.desc )

	t.id = t.desc
	t.Id = t.Desc

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

		self:RegenerateLocTable( agent )
		agent:RegenerateLocTable( self )

		self:GainXP( 10 )

		return true
	else
		return false
	end
end

function Agent:Interrupt( msg )
	if self:IsPuppet() and not self.world:IsPaused() then
		self.world:ScheduleInterrupt( 0, msg )
	end
end


function Agent:CanSee( obj )
	if self.location and self.location == obj:GetLocation() then
		return true
	end

	return false
end

function Agent:GetMarks( why )
	local t = {}
	for i, v in self.memory:Engrams() do
		if is_instance( v, Engram.Marked ) and (why == nil or v.why == why) then
			table.insert( t, v.obj )
		end
	end
	return t
end

function Agent:Mark( obj, why )
	if self.memory then
		self.memory:AddEngram( Engram.Marked( obj, why ))
	end
end

function Agent:Unmark( obj, why )
	if self.memory then
		local e = self.memory:FindEngram( 
			function( engram )
			return is_instance( engram, Engram.Marked ) and
			engram.obj == obj and
			(why == nil or engram.why == why) end )

		if e then
			self.memory:RemoveEngram( e )
		end
	end
end

function Agent:IsMarked( obj, why )
	if self.memory then
		return self.memory:HasEngram( function( engram )
			return is_instance( engram, Engram.Marked ) and
			engram.obj == obj and
			(why == nil or engram.why == why) end )
	end
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
	return self:GetStatValue( CORE_STAT.CHARISMA ) or 0
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
	end
end

function Agent:GetCoordinate()
	return self.x, self.y
end

function Agent:IsAdjacent( obj )
	local x, y = AccessCoordinate( obj )
	return x and y and IsAdjacentCoordinate( x, y, self.x, self.y )
end

function Agent:CanReach( entity )
	if entity.GetCarrier and entity:GetCarrier() == self.inventory then
		return true
	end

	local x, y = AccessCoordinate( entity )
	return x and y and (IsAdjacentCoordinate( x, y, self.x, self.y ) or (self.x == x and self.y == y))
end

function Agent:GetTile()
	if self.location then
		return self.location:GetTileAt( self.x, self.y )
	end
end

function Agent:TeleportToLocation( location, x, y )
	Msg:Echo( self, "You teleport to {1}", location:GetTitle() )
	self:WarpToLocation( location, x, y )
end

function Agent:Walk( dir )
	local x, y = OffsetDir( self.x, self.y, dir )
	local tile = self.location:GetTileAt( x, y )
	if tile and tile:IsPassable( self ) then
		self:WarpToTile( tile )
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

function Agent:WarpToTile( tile )
	local prev_tile = self.x and self.location:GetTileAt( self.x, self.y )
	if prev_tile then
		prev_tile:RemoveEntity( self )
	end

	self:SetCoordinate( tile:GetCoordinate() )

	tile:AddEntity( self )

	self:BroadcastEvent( ENTITY_EVENT.TILE_CHANGED, tile, prev_tile )
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
		if v:FindVerb( verb ) then
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
		local ok, reason = self:DoVerbAsync( verb )
		if not ok and reason then
			Msg:Echo( self, reason )
		end
	end
end

local function DoVerbCoroutine( self, verb, ... )
	self:_AddVerb( verb )

	verb:DoVerb( self, ... )

	self:_RemoveVerb( verb )
end

function Agent:DoVerbAsync( verb, ... )
	local ok, reason = verb:CanDo( self, ... )
	if not ok then
		print( "No can do!", self, verb, reason, ... )
		return false, reason
	end

	local coro = coroutine.create( DoVerbCoroutine )
	local ok, result = coroutine.resume( coro, self, verb, ... )
	if not ok then
		error( tostring(result) .. "\n" .. tostring(debug.traceback( coro )))
	end

	return true
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

function Agent:CalculateTimeElapsed( dt )
	if self.verbs then
		for i, verb in ipairs( self.verbs ) do
			dt = verb:CalculateTimeElapsed( dt )
		end
	end
	return dt
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

function Agent:GetFatigue()
	return self:GetStatValue( STAT.FATIGUE )
end

function Agent:HasEnergy( cost )
	local fatigue, max_fatigue = self:GetStatValue( STAT.FATIGUE )
	return fatigue + cost <= max_fatigue
end

function Agent:GainStatusEffect( class, stacks )
	if (stacks or 1) <= 0 then
		return
	end
	assert( not self:IsDead() )
	assert( is_class( class, Aspect.StatusEffect ))
	
	local aspect = self:GetAspect( class )
	if aspect == nil then
		aspect = self:GainAspect( class() )
	end

	aspect:GainStacks( stacks or 1 )
end


function Agent:Kill()
	assert( not self:IsDead() or error( "Already killed at: ".. self.killed_trace ))
	
	if self:IsPuppet() then
		self.world:TogglePause( PAUSE_TYPE.GAME_OVER )
	end

	print( self, "died!" )
	self.killed_trace = debug.traceback()

	Msg:ActToRoom( "{1.Id} dies!", self )
	Msg:Echo( self, "You die!" )

	self:GainAspect( Aspect.Killed() )
	self:LoseAspect( self:GetAspect( Aspect.Impass ))

	self:CancelInvalidVerbs()

	self:BroadcastEvent( AGENT_EVENT.DIED )
end

function Agent:IsDead()
	return self:HasAspect( Aspect.Killed )
end

function Agent:GetStatValue( stat )
	if self.stats[ stat ] then
		return self.stats[ stat ]:GetValue()
	end

	return 0
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
	table.insert( self.sense_log, { desc = txt, sensor_type = SENSOR.VISION, when = self.world and self.world:GetDateTime() or 0 } )
end

function Agent:Echo( txt )
	table.insert( self.sense_log, { desc = txt, sensor_type = SENSOR.ECHO, when = self.world and self.world:GetDateTime() or 0 } )
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

function Agent:GetAffinities( other )
	return self.affinities or table.empty
end

function Agent:GetAffinity( other )
	local affinity = self.affinities and self.affinities[ other ]
	if affinity then
		return affinity:GetAffinity()
	else
		return AFFINITY.STRANGER
	end
end

function Agent:DeltaTrust( trust, other )
	other = other or self.world:GetPlayer()
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

-- How much trust do I have with 'other'?
function Agent:GetTrust( other )
	local affinity = self.affinities and self.affinities[ other ]
	if affinity == nil then
		return 0
	else
		return affinity:GetTrust()
	end
end

function Agent:RewardXP( xp, reason )
	if self.stats[ STAT.XP ] then
		self:DeltaStat( STAT.XP, xp )
		Msg:Echo( self, "You gain {1} xp! ({2})", xp, reason )
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
	local viewer = self.world:GetPuppet()
	
	love.graphics.setFont( assets.FONTS.MAP_TILE )
	local ch, clr = self:GetMapChar()
	if self:IsDead() then
		clr = constants.colours.BLACK
	end

	local scale = DEFAULT_ZOOM / screen.camera:GetZoom()
	if self.image then
		screen:SetColour( clr or 0xFFFFFFFF )
		screen:Image( self.image, x1, y1, x2 - x1, y2 - y1 )
	else
		love.graphics.setColor( table.unpack( clr or constants.colours.WHITE ))
		love.graphics.print( ch or "?", x1 + (x2-x1)/6, y1, 0, 1.4 * scale, 1 * scale )
	end

	-- Show as a target in combat
	local combat = self:GetAspect( Aspect.Combat )
	if self.world and combat and combat:IsTarget( viewer ) then
		screen:SetColour( constants.colours.RED )
		love.graphics.print( "!", (x1+x2)*0.5, (y1), 0, scale, 0.6 * scale )
	end

	-- Show as someone familiar.
	if viewer:GetAffinity( self ) ~= AFFINITY.STRANGER or self:GetTrust( viewer ) > 0 then
		screen:SetColour( constants.colours.YELLOW )
		love.graphics.print( "*", x1, (y1), 0, scale, 0.6 * scale )		
	end
	-- Show someone who is marked.
	if viewer:IsMarked( self ) then
		screen:SetColour( constants.colours.RED )
		love.graphics.print( "*", x1+(x2-x1)*0.2, (y1), 0, scale, 0.6 * scale )		
	end

	if self:IsSleeping() then
		local img = assets.IMG.ZZZ
		screen:SetColour( constants.colours.WHITE )
		local w, h = (x2 - x1)*0.8, (y2 - y1)*0.8
		screen:Image( img, x1+(x2-x1)*0.5, y1-(y2-y1)*0.5, w, h )
	end
end

function Agent:__tostring()
	return string.format( "%s%s%s%s",
		self:IsPlayer() and "@" or "",
		self:GetShortDesc(),
		self.location == nil and "*" or "",
		self:IsDead() and "!" or "" )
end


