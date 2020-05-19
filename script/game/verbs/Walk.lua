local Walk = class( "Verb.Walk", Verb )

function Walk:init( exit )
	self.exit = exit
end

function Walk:Interact( actor )
	local location = actor:GetLocation()
	local x0, y0 = actor:GetCoordinate()
	local x, y = OffsetExit( x0, y0, self.exit )
	local tile = location:GetTileAt( x, y )
	if tile and tile:IsPassable( actor ) then
		actor:WarpToTile( tile )

		if actor:IsRunning() then
			actor:DeltaStat( STAT.FATIGUE, 2 )
			self:YieldForTime( RUN_TIME )
		else
			self:YieldForTime( WALK_TIME )
		end
	end
end
