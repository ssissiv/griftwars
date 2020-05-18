local LootObject = class( "Verb.LootObject", Verb )

function LootObject:GetRoomDesc( actor )
	return loc.format( "Get {1}", tostring(self.obj))
end

function LootObject:CanInteract( actor, obj )
	if obj:GetCarrier() == actor:GetInventory() then
		return false, "Already owned"
	elseif obj:GetCarrier() == nil then
		if not actor:CanReach( obj ) then
			return false, "Can't reach"
		end
	end
	if not obj:GetAspect( Aspect.Carryable ) then
		return false -- Not even carryable
	end
	return true
end

function LootObject:Interact( actor, obj )
	if obj:GetCarrier() == nil then
		local tile = obj:GetTile()
		if tile then
			tile:RemoveEntity( obj )
		end
		actor:GetInventory():AddItem( obj )
	else
		Msg:Echo( actor, "You pick up {1}.", obj:GetName( actor ))
		obj:GetCarrier():TransferItem( obj, actor:GetInventory() )
	end
end

-------------------------------------------------------------

local LootAll = class( "Verb.LootAll", Verb )

function LootAll:init( inventory )
	Verb.init( self, nil, inventory )
	self.inventory = inventory
end

function LootAll:GetRoomDesc( actor )
	return "Loot all"
end

function LootAll:Interact( actor, inventory )
	inventory = inventory or self.inventory

	self.loot = self.loot or Verb.LootObject()
	for i, obj in inventory:Items() do
		self.loot:DoVerb( actor, obj )
	end
end
