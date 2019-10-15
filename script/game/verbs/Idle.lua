local Idle = class( "Verb.Idle", Verb )

function Idle:GetDesc()
	return "Idle"
end

function Idle:Interact( actor )
	-- Idling.
	Msg:Speak( "Just idling!", actor )
	self:YieldForTime( ONE_HOUR )
end

