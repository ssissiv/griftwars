local Walk = class( "Verb.Walk", Verb )

function Walk:init( actor, dir )
	Verb.init( self, actor )
	self.dir = dir
end

function Walk:GetDesc( viewer )
	if self.actor:InCombat() then
		return "Walking"
	else
		return "Running"
	end
end

function Walk:GetActDesc()
	return loc.format( "{1} {2}", self.running and "Run" or "Walk", self.dir )
end

function Walk:SetDirection( dir )
	self.dir = dir
end

function Walk:CanInteract()
	local actor = self.actor
	if not actor:HasEnergy( 2 ) then
		return false, "Too tired"
	end

	local x, y = actor:GetCoordinate()
	x, y = OffsetDir( x, y, self.dir )
	local tile = actor:GetLocation():LookupTile( x, y )
	if not tile or not tile:IsPassable( actor ) then
		return false, "Not passable"
	end

	return Verb.CanInteract( self )
end

function Walk:Interact()
	local actor = self.actor
	self.running = actor:InCombat()

	if not actor:MoveDirection( self.dir ) then
		assert_warning( false, "Oops?" )
	end

	local move_time
	if self.running then
		actor:DeltaStat( STAT.FATIGUE, 1 )
		move_time = RUN_TIME * actor:CalculateMoveSpeed()
	else
		actor:DeltaStat( STAT.FATIGUE, 0.1 )
		move_time = WALK_TIME * actor:CalculateMoveSpeed()
	end

	if actor:InCombat() then
		self:YieldForTime( move_time, "rate", 0.1 )
	else
		self:YieldForTime( move_time, "instant" )
	end
end
