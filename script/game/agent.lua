local FLAGS = MakeEnum{
	"PLAYER"
}

local Agent = class( "Agent" )
Agent.FLAGS = FLAGS

function Agent:init()
	self.flags = {}
	self.aspects = {}
	self.sense_log = {}
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

function Agent:IsPlayer()
	return self:HasFlag( FLAGS.PLAYER )
end

function Agent:GetShortDesc()
	if self:IsPlayer() then
		return "You are here."
	else
		return loc.format( "{1} is standing here.", self.name )
	end
end

function Agent:CollectInteractions( obj, verbs )
	for i, aspect in self:Aspects() do
		if aspect:CanInteract( self, obj ) then
			if verbs then
				table.insert( verbs, aspect )
			else
				return true
			end
		end
	end
	if obj then
		for i, aspect in obj:Aspects() do
			if aspect:CanInteract( self, obj ) then
				if verbs then
					table.insert( verbs, aspect )
				else
					return true
				end
			end
		end

	elseif self.location then
		for i, feature in self.location:Aspects() do
			if feature:CanInteract( self ) then
				if verbs then
					table.insert( verbs, feature )
				else
					return true
				end
			end
		end
	end

	if verbs then
		return verbs
	end
end

function Agent:SetDetails( name )
	self.name = name
end

function Agent:MoveToLocation( location )
	if self.location then
		self.location:RemoveAgent( self )
		self.location = nil
	end

	if location then
		self.location = location
		location:AddAgent( self )
	end
end

function Agent:GetLocation()
	return self.location
end

function Agent:GainAspect( aspect )
	table.insert( self.aspects, aspect )
	aspect:OnGainAspect( self )
end

function Agent:LoseAspect( aspect )
	table.arrayremove( self.aspects, aspect )
	aspect:OnLoseAspect( self )
end

function Agent:Aspects()
	return ipairs( self.aspects )
end

function Agent:CanSee( obj )
	return true
end

function Agent:Sense( txt )
	table.insert( self.sense_log, txt )
end

function Agent:Senses()
	return ipairs( self.sense_log )
end

function Agent:__tostring()
	return self:GetName()
end


