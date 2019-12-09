local Subordinate = class( "Relationship.Subordinate", Relationship )

function Subordinate:init( boss, subordinate )
	Relationship.init( self )

	assert( boss ~= subordinate )
	self.boss = self:AddAgent( boss )
	self.subordinate = self:AddAgent( subordinate )
end

function Subordinate:CheckPrivacy( owner, target, flag )
	if owner == self.boss and target == self.subordinate then
		return CheckBits( PRIVACY_ALL, flag )
	elseif owner == self.subordinate and target == self.boss then
		return CheckBits( bit.bor( PRIVACY.ID, PRIVACY.LOOKS, PRIVACY.HAUNTS ), flag )
	end
	return false
end
