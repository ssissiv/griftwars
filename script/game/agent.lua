local FLAGS = MakeEnum{
	"PLAYER"
}

local Agent = class( "Agent", Entity )
Agent.FLAGS = FLAGS

function Agent:init()
	Entity.init( self )
	self.prestige = 1
	self.flags = {}
	self.stats = {}
	self.sense_log = {} -- array of strings
	self.potential_verbs = VerbContainer()
	self.inventory = Inventory( self )
	self.social_node = SocialNode( self )
	self.viz = AgentViz()
	self.mental_state = MSTATE.ALERT

	self:CreateStat( STAT.FATIGUE, 0, 100 ):DeltaRegen( 100 / (2 * ONE_DAY) )

	-- self:CreateStat( STAT.STATURE, 1, 1 ):SetGrowthRate( 0.1 )
	-- self:CreateStat( STAT.MIND, 1, 1 ):SetGrowthRate( 0.1 )
	-- self:CreateStat( STAT.CHARISMA, 1, 1 ):SetGrowthRate( 0.1 )
end

function Agent:SetFlags( ... )
	for i, flag in ipairs({...}) do
		self.flags[ flag ] = true
	end
end

function Agent:SetMentalState( state )
	assert( IsEnum( state, MSTATE ))
	self.mental_state = state
end

function Agent:IsAlert()
	return self.mental_state == MSTATE.ALERT
end

function Agent:HasFlag( flag )
	return self.flags[ flag ] == true
end

function Agent:GetName()
	return self.name or "No Name"
end

function Agent:GetDesc()
	return self.desc or "No Desc"
end

function Agent:IsPlayer()
	return self:HasAspect( Trait.Player )
end

function Agent:GetPlayer()
	return self:GetAspect( Trait.Player )
end

function Agent:GetDice()
	return self:GetAspect( Trait.Player ):GetDice() -- Only player has dice atm.
end

function Agent:IsPuppet()
	return self.world:GetPuppet() == self
end

function Agent:GetShortDesc( viewer )
	local desc
	if self.verbs and #self.verbs > 0 then
		-- TODO: primary verb?
		desc = self.verbs[1].verb:GetShortDesc( viewer )
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

function Agent:CollectPotentialVerbs()
	local now = self.world:GetDateTime()
	if now <= (self.verb_time or 0) then
		return
	end

	-- FIXME: figure out a way to avoid churning this search.
	self.verb_time = now + 1

	-- if actor == nil or actor == self then
	-- 	verbs = self.potential_verbs
	-- 	table.clear( verbs )
	-- else
	-- 	assert( verbs )
	-- end

	self.potential_verbs:ClearVerbs()
	self:BroadcastEvent( AGENT_EVENT.COLLECT_VERBS, self.potential_verbs )

	Verb.RecurseSubclasses( nil, function( class )
		if class.CollectInteractions then
			class.CollectInteractions( self, self.potential_verbs )
		end
	end )

	return self.potential_verbs
end

function Agent:GetPotentialVerbs()
	self:CollectPotentialVerbs()
	return self.potential_verbs
end

function Agent:PotentialVerbs()
	self:CollectPotentialVerbs()
	return self.potential_verbs:Verbs()
end

function Agent:SetDetails( name, desc, gender )
	self.name = name
	self.desc = desc
	self.gender = gender
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
		t.himher = "him"
		t.hishers = "his"
		t.heshe = "he"
		t.HeShe = "He"

	elseif self.gender == GENDER.FEMALE then
		t.himher = "her"
		t.hishers = "hers"
		t.heshe = "she"
		t.HeShe = "She"

	else
		t.himher = "it"
		t.hisher = "its"
		t.heshe = "it"
		t.HeShe = "It"
	end

	if viewer == nil then
		t.id = loc.format( "[[{1}]]", self.name )
		t.Id = t.id
	elseif viewer:CheckPrivacy( self, PRIVACY.ID ) then
		t.id = loc.format( "[{1}]", self.name )
		t.Id = t.id
	else
		t.id = "[Unknown]"
		t.Id = t.id
	end

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
	return self.memory -- Assigned by Trait.Memory when attained.
end

function Agent:IsAcquainted( agent )
	if not self:CheckPrivacy( agent, PRIVACY.ID ) then
		return false
	end
end

function Agent:Acquaint( agent )
	if self.memory and not self:IsAcquainted( agent ) then
		self.memory:AddEngram( Engram.MakeKnown( agent, PRIVACY.ID ))
		agent:RegenerateLocTable( self )

		self:GainXP( 10 )

		return true
	else
		return false
	end
end

function Agent:CheckPrivacy( obj, pr_flags )
	if self.memory then
		return self.memory:CheckPrivacy( obj, pr_flags )
	end
end

function Agent:_AddRelationship( r )
	if self.relationships == nil then
		self.relationships = {}
	end
	table.insert( self.relationships, r )
end

function Agent:Relationships()
	return ipairs( self.relationships or table.empty )
end

function Agent:WarpToLocation( location )
	assert( location )

	local prev_location = self.location
	if self.location then
		self:SetFocus( nil )
		self.location:_RemoveAgent( self )
		self.location = nil
	end

	self.verb_time = nil

	if location then
		assert( self.world )
		self.location = location
		location:_AddAgent( self )
	end

	self:BroadcastEvent( AGENT_EVENT.LOCATION_CHANGED, prev_location, self.location )
end

function Agent:MoveToAgent( agent )
	self:WarpToLocation( agent:GetLocation() )
end

function Agent:GetLocation()
	return self.location
end

function Agent:IsBusy( flags )
	if self.verbs then
		for i, action in ipairs( self.verbs ) do
			if action.verb:IsBusy( flags ) then
				return true
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

-- DEPRECATED
function Agent:IsDoing( verb )
	for i, action in ipairs( self.verbs or table.empty ) do
		if action.verb == verb then
			return true
		end
	end
	return false
end

function Agent:DoVerb( verb )
	local ok, reason = verb:CanInteract( self )
	if ok then
		if self.verbs == nil then
			self.verbs = {}
		else
			assert( not self:IsDoing( verb ), tostring(self)..tostring(verb))
		end
		local action =
		{
			verb = verb,
			coro = coroutine.create( verb._BeginActing )
		}
		table.insert( self.verbs, action )
	--	assert( #self.verbs == 1 )

		local ok, result = coroutine.resume( action.coro, action.verb, self )
		if not ok then
			error( tostring(result) .. "\n" .. tostring(debug.traceback( action.coro )))
		end

		-- if coroutine.status( action.coro ) ~= "suspended" then



	else
		print( "cant do", self, verb, reason )
	end
end

function Agent:_RemoveVerb( verb )
	for i, action in ipairs( self.verbs ) do
		if verb == action.verb then
			table.remove( self.verbs, i )
			if #self.verbs == 0 then
				self.verbs = nil
			end
			self:BroadcastEvent( AGENT_EVENT.VERB_UNASSIGNED, verb )
			break
		end
	end
end

function Agent:Verbs()
	return ipairs( self.verbs or table.empty )
end

function Agent:CancelInvalidVerbs()
	if self.verbs then
		for i = #self.verbs, 1, -1 do
			local verb = self.verbs[i].verb
			if not verb:CanInteract() then
				verb:Cancel()
			end
		end
	end
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
		Msg:Echo( self, "You gain {1} {2}!", delta, stat )
	end
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

		if self:IsPlayer() then
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

		if self:IsPlayer() then
			self.world:TogglePause( PAUSE_TYPE.FOCUS_MODE) 
		end
	end

	-- Focus probably changes verb eligibility.
	self:CancelInvalidVerbs()
	self.verb_time = nil

	print( "CHANGE FOCUS", self, self.focus )
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
	self.verb_time = nil
end

function Agent:GetSocialNode()
	return self.social_node
end

function Agent:GetOpinion( other )
	return self.social_node:GetOpinion( other )
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

function Agent:DeltaOpinion( other, op, delta )
	self.social_node:DeltaOpinion( other, op, delta )
end

function Agent:RenderObject( ui, viewer )
	self.social_node:RenderObject( ui, viewer )
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

function Agent:__tostring()
	return string.format( "[%s%s%s]",
		self:IsPlayer() and "@" or "",
		self:GetName(),
		self.location == nil and "*" or "" )
end


