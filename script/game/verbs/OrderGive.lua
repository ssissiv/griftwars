
local OrderGive = class( "Verb.OrderGive", Verb )

OrderGive.VERB_DURATION = 0

function OrderGive.CollectInteractions( actor, verbs )
	local leader = actor:GetLeader()
	if leader then
		local order = leader:GetAspect( Trait.Leader ):FindOrder( function( order )
				return order._class == OrderGive and order.obj == actor
			end )
		if order then
			table.insert( verbs, order )
		end
	end
end

function OrderGive:Interact( actor )
	Msg:Speak( "I must deliver my loot to {1.name}", actor, self.obj:LocTable() )
	-- self:TravelTo( self.obj )

	-- self.owner:GetInventory():GiveAll( self.obj )
end
