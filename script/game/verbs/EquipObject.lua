local EquipObject = class( "Verb.EquipObject", Verb )

function EquipObject:init( actor, obj )
	Verb.init( self, actor )
	assert( is_instance( obj, Object ))
	self.obj = obj
end

function EquipObject:GetActDesc()
	local wearable = self.obj:GetAspect( Aspect.Wearable )
	if wearable and wearable:IsEquipped() then
		return loc.format( "Remove {1}", tostring(self.obj) )
	else
		return loc.format( "Equip {1}", tostring(self.obj) )
	end
end

function EquipObject:CanInteract()
	local wearable = self.obj:GetAspect( Aspect.Wearable )
	if not wearable then
		return false, "Cannot wear"
	end
	return true
end

function EquipObject:Interact()
	local wearable = self.obj:GetAspect( Aspect.Wearable )
	if wearable:IsEquipped() then
		Msg:EchoTo( self.actor, "You unequip {1}.", self.obj )
		wearable:Unequip()
	else
		Msg:EchoTo( self.actor, "You equip {1}.", self.obj )
		wearable:Equip()
	end
end
