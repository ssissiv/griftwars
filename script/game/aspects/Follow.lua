local Follow = class( "Verb.Follow", Verb )

function Follow:init( other, approach_dist )
	Verb.init( self, nil, other )
	self.approach_dist = approach_dist
	self.travel = self:AddChildVerb( Verb.Travel() )
end

function Follow:CanInteract( actor, other )
	-- if other:GetLocation() ~= actor:GetLocation() then
	-- 	return false, "Not here"
	-- end
	if other:IsDead() then
		return false
	end
	
	return true
end

function Follow:OnOtherEvent( event_name, ... )
	if event_name == ENTITY_EVENT.TILE_CHANGED then
		self:Unyield()
	end
end

function Follow:Interact( actor, other )
	other:ListenForAny( self, self.OnOtherEvent )
	actor:Mark( other )

	local z = 0
	while not self:IsCancelled() do
		if actor:GetLocation() ~= other:GetLocation() or EntityDistance( actor, other ) > 2 then
			self.travel:SetApproachDistance( self.approach_dist )
			self.travel:DoVerb( actor, other )
		end

		self:YieldForTime( ONE_HOUR )
	end

	actor:Unmark( other )
	other:RemoveListener( self )
end
