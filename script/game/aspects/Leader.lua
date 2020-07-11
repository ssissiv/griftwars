---------------------------------------------------------------
local Leader = class( "Trait.Leader", Aspect )

function Leader:init()
	self.followers = {}
end

function Leader:OnDespawn()
	Aspect.OnDespawn( self )

	while #self.followers > 0 do
		self.followers[1]:SetLeader( nil )
	end
end

function Leader:AddFollower( agent )
	table.insert( self.followers, agent )
end

function Leader:RemoveFollower( agent )
	assert( agent.leader == self.owner )
	table.arrayremove( self.followers, agent )
end

function Leader:Followers()
	return ipairs( self.followers )
end
