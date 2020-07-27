local Follow = class( "Verb.Follow", Verb )

Follow.INTENT_FLAGS = INTENT.STEALTH
Follow.act_desc = "Follow"

function Follow:init( other, approach_dist )
	Verb.init( self, nil, other )
	self.approach_dist = approach_dist or 4
	self.travel = Verb.Travel()
end

function Follow:CanInteract( actor, other )
	-- if other:GetLocation() ~= actor:GetLocation() then
	-- 	return false, "Not here"
	-- end
	if (other or self.obj):IsDead() then
		return false
	end
	
	return true
end

function Follow:OnOtherEvent( event_name, ... )
	if event_name == ENTITY_EVENT.TILE_CHANGED or event_name == AGENT_EVENT.LOCATION_CHANGED then
		self:Unyield()
	end
end

function Follow:OnActorEvent( event_name, ... )
	if event_name == ENTITY_EVENT.TILE_CHANGED or event_name == AGENT_EVENT.LOCATION_CHANGED then
		self:Unyield()
	end
end

function Follow:Interact( actor, other )
	other:ListenForAny( self, self.OnOtherEvent )
	actor:ListenForAny( self, self.OnActorEvent )
	actor:Mark( other, "following" )

	local z = 0
	while not self:IsCancelled() do
		if actor:GetLocation() ~= other:GetLocation() or EntityDistance( actor, other ) > self.approach_dist then
			self.travel:SetApproachDistance( self.approach_dist )
			self:DoChildVerb( self.travel, other )
			-- self.travel:DoVerb( actor, other )
		end

		-- If we receive TILE_CHANGED for us or the target, we will Unyield().
		self:YieldForTime( ONE_HOUR )
	end

	actor:Unmark( other, "following" )
	other:RemoveListener( self )
	actor:RemoveListener( self )
end
