---------------------------------------------------------------
local Follower = class( "Trait.Follower", Verb )

function Follower:init( leader )
	Verb.init( self )
	assert( is_instance( leader, Agent ))
	self.leader = leader
end

function Follower:CalculateUtility()
	return UTILITY.OATH
end

function Follower:Interact( actor )
	if not self:DoChildVerb( Verb.Follow( actor, self.leader )) then
		print( actor, "Couldn't follow", self.leader )
		self:YieldForTime( ONE_MINUTE )
	end
end
