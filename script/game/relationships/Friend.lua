local Friend = class( "Relationship.Friend", Relationship )

function Friend:init( first, second )
	Relationship.init( self )

	assert( first ~= second )
	self.first = self:AddAgent( first )
	self.second = self:AddAgent( second )
end

function Friend:CheckPrivacy( owner, target, flag )
	if (owner == self.first and target == self.second) or (owner == self.second and target == self.first) then
		return CheckBits( PRIVACY_ALL, flag )
	end
	return false
end

