local Wearable = class( "Aspect.Wearable", Aspect )

function Wearable:init( slot )
	self.eq_slot = slot
	self.equipped = false
end

function Wearable:IsEquipped()
	return self.equipped, self.eq_slot
end

function Wearable:GetEqSlot()
	return self.eq_slot
end

function Wearable:Equip()
	self.equipped = true
end

function Wearable:Unequip()
	self.equipped = false
end

function Wearable:CollectVerbs( verbs, actor, obj )
	if obj == self.owner then
		verbs:AddVerb( Verb.EquipObject( nil, self.owner ))
	end
end
