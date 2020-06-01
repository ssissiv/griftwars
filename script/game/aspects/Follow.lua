local Follow = class( "Verb.Follow", Verb )

function Follow:init( other, approach_dist )
	Verb.init( self, nil, other )
	self.approach_dist = approach_dist
end

function Follow:CanInteract( actor, other )
	-- if other:GetLocation() ~= actor:GetLocation() then
	-- 	return false, "Not here"
	-- end
	return true
end

function Follow:OnOtherEvent( event_name, ... )
	if event_name == AGENT_EVENT.TILE_CHANGED then
		local agent, x, y = ...
		self:Unyield()
	end
end

function Follow:Interact( actor, other )
	other:ListenForAny( self, self.OnOtherEvent )
	local z = 0
	while not self:IsCancelled() do
		if actor:GetLocation() ~= other:GetLocation() or EntityDistance( actor, other ) > 2 then
			local travel = Verb.Travel()
			travel:SetApproachDistance( self.approach_dist )
			travel:DoVerb( actor, other )
		end

		self:YieldForTime( ONE_HOUR )
	end

	other:RemoveListener( self )
end
