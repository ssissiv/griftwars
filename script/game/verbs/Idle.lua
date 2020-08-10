local Idle = class( "Verb.Idle", Verb )

function Idle:GetDesc()
	return "Idle"
end

function Idle:SetDuration( duration )
	self.duration = duration
	return self
end

function Idle:GetDesc( viewer )
	return "Idling in place"
end

function Idle:Interact()
	-- Idling.
	local time = self.world:GetDateTime() + (self.duration or 0)
	repeat
		-- Msg:Speak( actor, "Just idling!" )
		self:YieldForTime( ONE_MINUTE )

	until self:IsCancelled() or self.world:GetDateTime() >= time
end

function Idle:CalculateUtility()
	return 1 -- Beats alll 0.
end
