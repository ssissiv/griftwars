local EquipObject = class( "Verb.EquipObject", Verb )

function EquipObject:GetDesc()
	return "Un/Equip Object"
end

function EquipObject:CollectVerbs( verbs, actor, obj )
	if not self then
		return false
	end
	if not is_instance( obj, Object ) then
		return false
	end

	if obj.EQ_SLOT == nil then
		return false
	end

	verbs:AddVerb( EquipObject( actor, obj ))
end


function EquipObject:CanInteract( actor, obj )
	return true
end

function EquipObject:Interact( actor, obj )	
	if obj:IsEquipped() then
		Msg:Echo( actor, "You unequip {1}.", obj )
		obj:Unequip()
	else
		Msg:Echo( actor, "You equip {1}.", obj )
		obj:Equip()
	end
end
