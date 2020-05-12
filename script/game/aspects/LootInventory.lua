local LootInventory = class( "Verb.LootInventory", Verb )

function LootInventory:init( inventory )
	Verb.init( self, nil, inventory )
	self.inventory = inventory
end

function LootInventory:Interact( actor, inventory )
	inventory = inventory or self.obj

	for i, item in inventory:Items() do
		Msg:Echo( actor, "You loot {1} from {2}.", item:GetName( actor ), inventory.owner:GetName( actor ))
	end
	inventory:TransferAll( actor:GetInventory() )
end
