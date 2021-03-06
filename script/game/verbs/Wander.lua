local Wander = class( "Verb.Wander", Verb )

function Wander:GetDesc( viewer )
	return "Wandering"
end

function Wander:SetDuration( duration )
	self.duration = duration
	return self
end

function Wander:Interact()
	local actor = self.actor
	-- Idling.
	local time = self.world:GetDateTime() + (self.duration or 0)
	repeat
		-- Msg:Speak( actor, "Just idling!" )
		self:YieldForTime( ONE_MINUTE )

		if actor:GetCoordinate() then
			local dirs = {}
			for i, dir in ipairs( EXIT_ARRAY ) do
				local x, y = actor:GetCoordinate()
				x, y = OffsetExit( x, y, dir )
				local tile = actor.location:LookupTile( x, y )
				if tile and tile:IsPassable( self ) then
					table.insert( dirs, dir )
				end
			end

			if #dirs > 0 then
				local dir = ExitToDir( table.arraypick( dirs ))
				actor:MoveDirection( dir )
			end
		end
	until self:IsCancelled() or self.world:GetDateTime() >= time
end

function Wander:CalculateUtility( actor )
	return 1 -- Beats alll 0.
end
