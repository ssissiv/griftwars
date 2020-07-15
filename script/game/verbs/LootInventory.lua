local LootInventory = class( "Verb.LootInventory", Verb )

function LootInventory:init( inventory )
	Verb.init( self, nil, inventory )
	self.inventory = inventory
end

function LootInventory:GetDesc( viewer )
	return "Looting"
end

function LootInventory:GetActDesc( actor )
	return loc.format( "Loot the {1}", tostring(self.inventory.owner))
end

function LootInventory:CanInteract( actor, inventory )
	inventory = inventory or self.obj

	if not actor:CanReach( inventory.owner ) then
		return false, "Not adjacent"
	end

	return true
end

function LootInventory:Interact( actor, inventory )
	inventory = inventory or self.obj

	if inventory:IsEmpty() then
		Msg:Echo( actor, "Nothing found!" )
	else
		actor.world.nexus:LootInventory( actor, inventory )
	end
end
