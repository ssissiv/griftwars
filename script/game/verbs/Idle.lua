local Idle = class( "Verb.Idle", Verb )

function Idle:GetDesc()
	return "Idle"
end

function Idle:Interact( actor )
	-- Idling.
	Msg:Speak( actor, "Just idling!" )
	self:YieldForTime( 5 * ONE_MINUTE )

	if actor:GetCoordinate() then
		local dir = table.arraypick( EXIT_ARRAY )
		actor:Walk( dir )
	end
end

function Idle:CalculateUtility( actor )
	return 1 -- Beats alll 0.
end
