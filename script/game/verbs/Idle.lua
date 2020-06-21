local Idle = class( "Verb.Idle", Verb )

function Idle:GetDesc()
	return "Idle"
end

function Idle:RenderAgentDetails( ui, screen, viewer )
	ui.Bullet()
	ui.Text( "Idling in place" )
end

function Idle:Interact( actor, target, duration )
	-- Idling.
	local time = self.world:GetDateTime() + (duration or 0)
	repeat
		-- Msg:Speak( actor, "Just idling!" )
		self:YieldForTime( ONE_MINUTE )

	until self:IsCancelled() or self.world:GetDateTime() >= time
end

function Idle:CalculateUtility( actor )
	return 1 -- Beats alll 0.
end
