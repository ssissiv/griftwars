local FLAGS = MakeEnum{
	"PLAYER"
}

local Agent = class( "Agent" )
Agent.FLAGS = FLAGS

function Agent:init()
	self.prestige = 1
	self.flags = {}
	self.aspects = {}
	self.sense_log = {}
	self.inventory = Inventory()
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
	for i, aspect in self:Aspects() do
		local ok, details = aspect:CanInteract( self, obj )
		if ok or details then
			if verbs then
				table.insert( verbs, aspect )
			else
				return true
			end
		end
	end
	if obj then
		for i, aspect in obj:Aspects() do
			local ok, details = aspect:CanInteract( self, obj )
			if ok or details then
				if verbs then
					table.insert( verbs, aspect )
				else
					return true
				end
			end
		end

	elseif self.location then
		for i, feature in self.location:Aspects() do
			local ok, details = feature:CanInteract( self )
			if ok or details then
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

function Agent:SetDetails( name, desc )
	self.name = name
	self.desc = desc
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

function Agent:SetFocus( focus )
	self.focus = focus
end

function Agent:GetFocus()
	return self.focus
end


function Agent:__tostring()
	return self:GetName()
end


