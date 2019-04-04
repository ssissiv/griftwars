local FLAGS = MakeEnum{
	"PLAYER"
}

local Agent = class( "Agent" )
Agent.FLAGS = FLAGS

function Agent:init()
	self.prestige = 1
	self.flags = {}
	self.aspects = {} -- array of Aspects
	self.aspects_by_id = {}
	self.stats = {}
	self.sense_log = {} -- array of strings
	self.inventory = Inventory( self )
	self.social_node = SocialNode( self )

	self:DeltaStat( STAT.STATURE, 1 )
	self:DeltaStat( STAT.MENTALITY, 1 )
	self:DeltaStat( STAT.CHARISMA, 1 )
end

function Agent:OnSpawn( world )
	assert( self.world == nil )
	self.world = world
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
	return self:HasFlag( FLAGS.PLAYER )
end

function Agent:IsPuppet()
	return self.world:GetPuppet() == self
end

function Agent:GetShortDesc()
	if self:IsPuppet() then
		return "You are here."
	else
		return loc.format( "{1} is standing here.", self.name )
	end
end

function Agent:CollectInteractions( obj, verbs )
	local found = false
	for i, aspect in self:Aspects() do
		if aspect.CollectInteractions and aspect:CollectInteractions( self, obj, verbs ) then
			found = true
		end
	end
	
	if obj then
		for i, aspect in obj:Aspects() do
			if aspect.CollectInteractions and aspect:CollectInteractions( self, obj, verbs ) then
				found = true
			end
		end

	elseif self.location then
		for i, feature in self.location:Aspects() do
			if feature.CollectInteractions and feature:CollectInteractions( self, obj, verbs ) then
				found = true
			end
		end
	end

	if verbs then
		return verbs
	else
		return found
	end
end

function Agent:CollectAllInteractions( verbs )
	if self.location then
		for i, obj in self.location:Contents() do
			self:CollectInteractions( obj, verbs )
		end
	end

	self:CollectInteractions( nil, verbs )
	
	return verbs
end

function Agent:SetDetails( name, desc, gender )
	self.name = name
	self.desc = desc
	self.gender = gender

	self:GenerateLocTable()
end

function Agent:GenerateLocTable()
	if self.gender == GENDER.MALE then
		self.himher = "him"
		self.hishers = "his"
		self.heshe = "he"

	elseif self.gender == GENDER.FEMALE then
		self.himher = "her"
		self.hishers = "hers"
		self.heshe = "she"

	else
		self.himher = "it"
		self.hisher = "its"
		self.heshe = "it"
	end
end

function Agent:GetPrestige()
	return self.prestige
end

function Agent:GetInventory()
	return self.inventory
end

function Agent:MoveToLocation( location )
	if self.location then
		self.location:RemoveAgent( self )
		self.location = nil
		self:SetFocus( nil )
	end

	if location then
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

function Agent:GainAspect( aspect )
	local id = aspect:GetID()
	table.insert( self.aspects, aspect )
	assert( self.aspects_by_id[ id ] == nil )
	self.aspects_by_id[ id ] = aspect
	if is_instance( aspect, Aspect.StatValue ) then
		self.stats[ id ] = aspect
	end
	aspect:OnGainAspect( self )
end

function Agent:LoseAspect( aspect )
	local id = aspect:GetID()
	assert( self.aspects_by_id[ id ] == aspect )
	table.arrayremove( self.aspects, aspect )
	self.aspects_by_id[ id ] = nil
	if is_instance( aspect, Aspect.StatValue ) then
		self.stats[ id ] = nil
	end
	aspect:OnLoseAspect( self )
end

function Agent:GetAspect( id )
	return self.aspects_by_id[ id ]
end

function Agent:Aspects()
	return ipairs( self.aspects )
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
	return aspect and aspect:GetValue() or 0
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
	self.focus = focus

	if self.verb and not self.verb:CanInteract( self, focus ) then
		self:SetVerb( nil )
	end
end

function Agent:GetFocus()
	return self.focus
end

function Agent:SetVerb( verb )
	self.verb = verb
end

function Agent:GetVerb()
	return self.verb
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

function Agent:__tostring()
	return self:GetName()
end


