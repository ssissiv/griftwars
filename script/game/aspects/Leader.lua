---------------------------------------------------------------
local Leader = class( "Trait.Leader", Aspect )

function Leader:init()
	self.followers = {}
	self.orders = {}
end

function Leader:AddFollower( agent )
	table.insert( self.followers, agent )
	agent:SetLeader( self.owner )
	agent:ListenForEvent( AGENT_EVENT.VERB_UNASSIGNED, self, self.OnVerbUnassigned )
	self:RefreshOrders()
end

function Leader:RemoveFollower( agent )
	table.arrayremove( self.followers, agent )
	agent:SetLeader( nil )
	agent:RemoveListener( self )
	self:RefreshOrders()
end

function Leader:Followers()
	return ipairs( self.followers )
end

function Leader:FindOrder( fn )
	for i, order in ipairs( self.orders ) do
		if fn( order ) then
			return order
		end
	end
end

function Leader:OnVerbUnassigned( event_name, follower, verb )
	self:RefreshOrders()
end


function Leader:EvaluateOrders( orders )
	error() -- subclases should insert Verbs into the order array.
end


function Leader:RefreshOrders()
	table.clear( self.orders )
	self:EvaluateOrders( self.orders )
end
