local Idle = class( "Verb.Idle", Verb )

function Idle:GetDesc()
	return "Idle"
end

function Idle:Interact( actor )
	-- Idling.
	Msg:Speak( actor, "Just idling!" )
	self:YieldForTime( 15 * ONE_MINUTE )
end

