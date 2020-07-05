local Walk = class( "Verb.Walk", Verb )

function Walk:init( dir )
	Verb.init( self )
	self.dir = dir
end

function Walk:Interact( actor )
	if actor:Walk( self.dir ) then
		actor:DeltaStat( STAT.FATIGUE, 2 )
		self:YieldForTime( RUN_TIME, "instant" )
	else
		self:YieldForTime( WALK_TIME, "instant" )
	end
end
