local LootInventory = class( "Verb.LootInventory", Verb )

function LootInventory:init( actor, inventory )
	Verb.init( self, actor )
	self.inventory = inventory
end

function LootInventory:GetDesc( viewer )
	return "Looting"
end

function LootInventory:GetActDesc()
	return loc.format( "Loot the {1}", tostring(self.inventory.owner))
end

function LootInventory:CanInteract()
	if not self.actor:CanReach( self.inventory.owner ) then
		return false, "Not adjacent"
	end

	return true
end

function LootInventory:Interact()

	if self.inventory:IsEmpty() then
		Msg:EchoTo( self.actor, "Nothing found!" )
	else
		self.actor.world.nexus:LootInventory( self.actor, self.inventory )
	end
end
