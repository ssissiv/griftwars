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
	self.potential_verbs = {}
	self.inventory = Inventory( self )
	self.social_node = SocialNode( self )
	self.viz = AgentViz()

	self:CreateStat( STAT.STATURE, 1, 1 ):DeltaRegen( 1 )
	self:CreateStat( STAT.MENTALITY, 1, 1 ):DeltaRegen( 1 )
	self:CreateStat( STAT.CHARISMA, 1, 1 ):DeltaRegen( 1 )
end

function Agent:SetFlags( ... )
	for i, flag in ipairs({...}) do
		self.flags[ flag ] = true
	end
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

function Agent:IsPuppet()
	return self.world:GetPuppet() == self
end

function Agent:GetShortDesc( viewer )
	local desc
	if self.verbs and #self.verbs > 0 then
		-- TODO: primary verb?
		desc = self.verbs[1]:GetShortDesc( viewer )
	end

	if desc == nil then
		desc = loc.format( "{1.Id} is standing here.", self:LocTable( viewer ) )
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

function Agent:CollectInteractions( actor, verbs )
	local now = self.world:GetDateTime()
	if now <= (self.verb_time or 0) then
		return self.potential_verbs
	end

	-- FIXME: figure out a way to avoid churning this search.
	self.verb_time = now + 1

	if actor == nil or actor == self then
		verbs = self.potential_verbs
		table.clear( verbs )
	else
		assert( verbs )
	end

	Verb.RecurseSubclasses( nil, function( class )
		if class.CollectInteractions then
			class.CollectInteractions( self, verbs )
		end
	end )

	return self.potential_verbs
end

function Agent:PotentialVerbs()
	return ipairs( self.potential_verbs )
end

function Agent:MatchTarget( target )
	return target == self
end

function Agent:SetDetails( name, desc, gender )
	self.name = name
	self.desc = desc
	self.gender = gender
end

function Agent:RegenerateLocTable( viewer )
	self.loc_table = self:GenerateLocTable( viewer )
end

function Agent:LocTable( viewer )
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

	if viewer == nil or viewer:CheckPrivacy( self, PRIVACY.ID ) then
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
	return self.memory
end

function Agent:CheckPrivacy( obj, pr_flags )
	if self.memory then
		return self.memory:CheckPrivacy( obj, pr_flags )
	end
end

function Agent:MoveToLocation( location )
	assert( location )

	if self.location then
		self.location:RemoveAgent( self )
		self:SetFocus( nil )
		self.location = nil
	end

	self.verb_time = nil

	if location then
		assert( self.world )
		self.location = location
		location:AddAgent( self )
	end
end

function Agent:MoveToAgent( agent )
	self:MoveToLocation( agent:GetLocation() )
end

function Agent:GetLocation()
	return self.location
end

function Agent:IsBusy()
	return self.verbs and #self.verbs > 0
end

function Agent:AssignVerb( verb )
	if self.verbs == nil then
		self.verbs = {}
	end
	table.insert( self.verbs, verb )
end

function Agent:UnassignVerb( verb )
	table.arrayremove( self.verbs, verb )
	if #self.verbs == 0 then
		self.verbs = nil
	end
	self:BroadcastEvent( AGENT_EVENT.VERB_UNASSIGNED, verb )
end

function Agent:Verbs()
	return ipairs( self.verbs or table.empty )
end

function Agent:CancelInvalidVerbs()
	if self.verbs then
		for i = #self.verbs, 1, -1 do
			local verb = self.verbs[i]
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
	local aspect = self:GetAspect( stat )
	if aspect == nil then
		aspect = Aspect.StatValue( stat )
		self:GainAspect( aspect )
	end

	aspect:DeltaValue( delta )
end

function Agent:GetStat( stat )
	local aspect = self:GetAspect( stat )
	if aspect then
		return aspect:GetValue()
	end
	
	return 0
end

function Agent:Stats()
	return pairs( self.stats )
end

function Agent:CanSee( obj )
	return true
end

function Agent:Sense( txt )
	table.insert( self.sense_log, txt )
end

function Agent:Echo( txt )
	table.insert( self.sense_log, txt )
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

		self.social_node:EndDialog()
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
			focus.social_node:BeginDialog()
		end
	end

	-- Focus probably changes verb eligibility.
	self:CancelInvalidVerbs()
	self.verb_time = nil
end

function Agent:GetFocus()
	return self.focus
end

function Agent:OnLostFocus( other )
	-- other stop focussing on us, end any existing dialog
	self.social_node:EndDialog()

	if self.focus == other then
		self:SetFocus( nil )
	end
end

function Agent:OnReceivedFocus( other )
	local noticed = true
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

function Agent:DeltaOpinion( other, op, delta )
	self.social_node:DeltaOpinion( other, op, delta )
end

function Agent:RenderObject( ui, viewer )
	self.social_node:RenderObject( ui, viewer )
end

function Agent:__tostring()
	return string.format( "[%s%s%s]",
		self:IsPlayer() and "@" or "",
		self:GetName(),
		self.location == nil and "*" or "" )
end


