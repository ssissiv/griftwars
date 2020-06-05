local Idle = class( "Verb.Idle", Verb )

function Idle:GetDesc()
	return "Idle"
end

function Idle:Interact( actor, target, duration )
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
				actor:Walk( table.arraypick( dirs ))
			end
		end
	until not self:IsCancelled() and self.world:GetDateTime() >= time
end

function Idle:CalculateUtility( actor )
	return 1 -- Beats alll 0.
end
