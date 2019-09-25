
local Deliver = class( "Verb.Deliver", Verb )

function Deliver.CollectInteractions( actor, verbs )
	local leader = actor:GetLeader()
	if leader then
		local order = leader:GetAspect( Trait.Leader ):FindOrder( function( order )
				return order._class == Deliver and order.obj == actor
			end )
		if order then
			table.insert( verbs, order )
		end
	end
end

function Deliver:Interact( actor )
	Msg:ActToRoom( "{1.Id} gives something to {2.Id}.", actor, target )
	for i, item in self.owner:GetInventory():Items() do		
		Msg:Echo( actor, "You give {1} to {2.Id}.", item, target )
		Msg:Echo( target, "{1.Id} gives you {2}.", actor, item )
	end
end
