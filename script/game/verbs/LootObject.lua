local LootObject = class( "Verb.LootObject", Verb )

function LootObject:GetRoomDesc( actor )
	return loc.format( "Get {1}", tostring(self.obj))
end

function LootObject:CanInteract( actor, obj )
	if obj.owner == actor:GetInventory() then
		return false, "Already owned"
	end
	return true
end

function LootObject:Interact( actor, obj )
	if obj.owner == nil then
		actor:GetInventory():AddItem( obj )
	else
		Msg:Echo( actor, "You pick up {1}.", obj:GetName( actor ))
		obj.owner:TransferItem( obj, actor:GetInventory() )
	end
end
