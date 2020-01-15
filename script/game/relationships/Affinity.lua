local Affinity = class( "Relationship.Affinity", Relationship )

function Affinity:init( first, second, affinity )
	Relationship.init( self )

	self.first = self:AddAgent( first )
	self.second = self:AddAgent( second )
	self.affinity = affinity or AFFINITY.STRANGER
end

function Affinity:GetOther( agent )
	if agent == self.first then
		return self.second
	elseif agent == self.second then
		return self.first
	end
end

function Affinity:GetAffinity()
	return self.affinity
end

function Affinity:OnSpawn( world )
	Relationship.OnSpawn( self, world )
	self:SetAffinity( self.affinity )
end

function Affinity:SetAffinity( affinity )
	assert( IsEnum( affinity, AFFINITY ))
	self.affinity = affinity

	if (self.first:IsPuppet() or self.second:IsPuppet()) and affinity ~= AFFINITY.STRANGER then
		self.world.nexus:ShowAffinityChanged( self )
	end
end

function Affinity:CheckPrivacy( owner, target, flag )
	if (owner == self.first and target == self.second) or (owner == self.second and target == self.first) then
		return CheckBits( PRIVACY_ALL, flag )
	end
	return false
end
