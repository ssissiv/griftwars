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
		local current_tile = location:GetTileAt( x0, y0 )
		current_tile:RemoveEntity( actor )

		actor:SetCoordinate( x, y )

		tile:AddEntity( actor )

		actor:BroadcastEvent( AGENT_EVENT.TILE_CHANGED, x, y )

		self:YieldForTime( WALK_TIME )
	end
end
