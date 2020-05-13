local LootInventory = class( "Verb.LootInventory", Verb )

function LootInventory:init( inventory )
	Verb.init( self, nil, inventory )
	self.inventory = inventory
end

function LootInventory:CanInteract( actor, inventory )
	inventory = inventory or self.obj

	if not actor:IsAdjacent( inventory ) then
		return false, "Not adjacent"
	end

	return true
end

function LootInventory:Interact( actor, inventory )
	inventory = inventory or self.obj

	if inventory:IsEmpty() then
		Msg:Echo( actor, "Nothing found!" )
	else
		for i, item in inventory:Items() do
			Msg:Echo( actor, "You loot {1} from {2}.", item:GetName( actor ), inventory.owner:GetName( actor ))
		end
		inventory:TransferAll( actor:GetInventory() )
	end
end
