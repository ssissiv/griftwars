---------------------------------------------------------------
local Follower = class( "Trait.Follower", Verb )

function Follower:init( leader )
	Verb.init( self )
	assert( is_instance( leader, Agent ))
	self.leader = leader
	self.follow = Verb.Follow( self.leader, 1 )
	self.follow:SetTarget( self.leader )
end

function Follower:CalculateUtility()
	return UTILITY.OATH
end

function Follower:Interact( actor )
	if not self:DoChildVerb( self.follow, self.leader ) then
		print( actor, "Couldn't follow", self.leader )
		self:YieldForTime( ONE_MINUTE )
	end
end
