local Collector = class( "Trait.Collector", Trait.Leader )

function Collector:EvaluateOrders( orders )
	for i, follower in ipairs( self.followers ) do
		if follower:GetInventory():CalculateValue() > 0 then
			table.insert( orders, Verb.OrderGive( self.owner, follower ))
		end
	end
end

function Agent.Collector()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
	ch:GainAspect( Trait.Collector() )
	ch:GainAspect( Aspect.Behaviour() )
 	return ch
end

