
local OrderGive = class( "Verb.OrderGive", Verb )

function OrderGive:Interact( actor )
	Msg:ActToRoom( "{1.Id} gives something to {2.Id}.", actor, target )
	for i, item in self.owner:GetInventory():Items() do		
		Msg:Echo( actor, "You give {1} to {2.Id}.", item, target )
		Msg:Echo( target, "{1.Id} gives you {2}.", actor, item )
	end
end
