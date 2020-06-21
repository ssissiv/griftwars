local Wander = class( "Verb.Wander", Verb )

function Wander:GetDesc()
	return "Wander"
end

function Wander:RenderAgentDetails( ui, screen, viewer )
	ui.Bullet()
	ui.Text( "Idling (wandering)" )
end

function Wander:Interact( actor, target, duration )
	-- Idling.
	local time = self.world:GetDateTime() + (duration or 0)
	repeat
		-- Msg:Speak( actor, "Just idling!" )
		self:YieldForTime( ONE_MINUTE )

		if actor:GetCoordinate() then
			local dirs = {}
			for i, dir in ipairs( EXIT_ARRAY ) do
				local x, y = actor:GetCoordinate()
				x, y = OffsetExit( x, y, dir )
				local tile = actor.location:GetTileAt( x, y )
				if tile and tile:IsPassable( self ) then
					table.insert( dirs, dir )
				end
			end

			if #dirs > 0 then
				local dir = ExitToDir( table.arraypick( dirs ))
				actor:Walk( dir )
			end
		end
	until self:IsCancelled() or self.world:GetDateTime() >= time
end

function Wander:CalculateUtility( actor )
	return 1 -- Beats alll 0.
end
