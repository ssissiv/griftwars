local Walk = class( "Verb.Walk", Verb )

function Walk:init( dir )
	Verb.init( self )
	self.dir = dir
end

function Walk:GetDesc( viewer )
	if self.actor:InCombat() then
		return "Walking"
	else
		return "Running"
	end
end

function Walk:GetRoomDesc()
	return loc.format( "{1} {2}", self.running and "Walk" or "Run", self.dir )
end

function Walk:SetDirection( dir )
	self.dir = dir
end

function Walk:CanInteract( actor )
	if not actor:HasEnergy( 2 ) then
		return false, "Too tired"
	end

	local x, y = actor:GetCoordinate()
	x, y = OffsetDir( x, y, self.dir )
	local tile = actor:GetLocation():GetTileAt( x, y )
	if not tile or not tile:IsPassable( actor ) then
		return false, "Not passable"
	end

	return true
end

function Walk:Interact( actor )
	self.running = actor:InCombat()

	if not actor:MoveDirection( self.dir ) then
		assert_warning( false, "Oops?" )
	end

	local move_speed = actor:CalculateMoveSpeed()
	if self.running then
		actor:DeltaStat( STAT.FATIGUE, 2 )
		self:YieldForTime( RUN_TIME * move_speed, "instant" )
	else
		actor:DeltaStat( STAT.FATIGUE, 1 )
		self:YieldForTime( WALK_TIME * move_speed, "instant" )
	end
end
