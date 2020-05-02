local EquipObject = class( "Verb.EquipObject", Verb )

function EquipObject:GetDesc()
	local wearable = self.obj:GetAspect( Aspect.Wearable )
	if wearable and wearable:IsEquipped() then
		return loc.format( "Remove {1}", tostring(self.obj) )
	else
		return loc.format( "Equip {1}", tostring(self.obj) )
	end
end

function EquipObject:CanInteract( actor, obj )
	local wearable = obj:GetAspect( Aspect.Wearable )
	if not wearable then
		return false, "Cannot wear"
	end
	return true
end

function EquipObject:Interact( actor, obj )	
	local wearable = obj:GetAspect( Aspect.Wearable )
	if wearable:IsEquipped() then
		Msg:Echo( actor, "You unequip {1}.", obj )
		wearable:Unequip()
	else
		Msg:Echo( actor, "You equip {1}.", obj )
		wearable:Equip()
	end
end
