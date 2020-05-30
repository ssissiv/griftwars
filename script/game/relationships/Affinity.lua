local Affinity = class( "Relationship.Affinity", Relationship )

function Affinity:init( first, second, affinity )
	Relationship.init( self )

	self.first = self:AddAgent( first )
	self.second = self:AddAgent( second )
	self.affinity = affinity or AFFINITY.STRANGER
	self.trust = 0
end

function Affinity:GetOther( agent )
	if agent == self.first then
		return self.second
	elseif agent == self.second then
		return self.first
	end
end

function Affinity:GetTrust()
	return self.trust
end

function Affinity:GetAffinity()
	return self.affinity
end

function Affinity:OnSpawn( world )
	Relationship.OnSpawn( self, world )
	self:SetAffinity( self.affinity )
end

function Affinity:DeltaTrust( trust )
	self.trust = self.trust + trust
end

function Affinity:SetAffinity( affinity )
	assert( IsEnum( affinity, AFFINITY ))
	self.affinity = affinity

	if affinity ~= AFFINITY.FRIEND then
		self.trust = 0
	end

	if (self.first:IsPuppet() or self.second:IsPuppet()) and affinity ~= AFFINITY.STRANGER then
		self.world.nexus:ShowAffinityChanged( self )
	end
end

function Affinity:CheckPrivacy( owner, target, flag )
	-- Are we checking for the people we're defined for?
	if (owner == self.first and target == self.second) or (owner == self.second and target == self.first) then
		if self.affinity == AFFINITY.KNOWN then
			return CheckBits( PRIVACY_ALL, flag )
		end
	end
	return false
end
