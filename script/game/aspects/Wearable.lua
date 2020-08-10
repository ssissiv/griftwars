local Wearable = class( "Aspect.Wearable", Aspect )

function Wearable:init( slot )
	self.eq_slot = slot
	self.equipped = false
end

function Wearable:IsEquipped( eq_slot )
	return self.equipped and (self.eq_slot == eq_slot or eq_slot == nil), self.eq_slot
end

function Wearable:GetEqSlot()
	return self.eq_slot
end

function Wearable:Equip()
	self.equipped = true

	local carrier = self.owner:GetCarrier().owner

	local inv = carrier:GetAspect( Aspect.Inventory )
	inv:AllocateSlot( self.eq_slot, self.owner )

	if self.owner.equipment_handlers then
		for event_name, fn in pairs( self.owner.equipment_handlers ) do
			carrier:ListenForEvent( event_name, self.owner, fn)
		end
	end
end

function Wearable:Unequip()
	if self.equipped then
		self.equipped = false

		local carrier = self.owner:GetCarrier().owner
		local inv = carrier:GetAspect( Aspect.Inventory )
		inv:DeallocateSlot( self.eq_slot, self.owner )

		if self.owner.equipment_handlers then
			carrier:RemoveListener( self.owner )
		end
	end
end

function Wearable:CollectVerbs( verbs, actor, obj )
	if obj == self.owner and obj:GetCarrier() == actor:GetInventory() then
		verbs:AddVerb( Verb.EquipObject( actor, obj ))
	end
end
