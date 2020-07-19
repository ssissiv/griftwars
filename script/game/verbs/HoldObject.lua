local HoldObject = class( "Verb.HoldObject", Verb )

function HoldObject:GetActDesc( actor )
	local wearable = self.obj:GetAspect( Aspect.Wearable )
	if wearable and wearable:IsEquipped() then
		return loc.format( "Release {1}", tostring(self.obj) )
	else
		return loc.format( "Hold {1}", tostring(self.obj) )
	end
end

function HoldObject:Interact( actor, obj )	
	obj = obj or self.obj
	local wearable = obj:GetAspect( Aspect.Wearable )
	if not wearable then
		wearable = obj:GainAspect( Aspect.Wearable( EQ_SLOT.HELD ))
	end
	if wearable:IsEquipped() then
		Msg:Echo( actor, "You release {1}.", obj )
		wearable:Unequip()
	else
		Msg:Echo( actor, "You hold {1}.", obj )
		wearable:Equip()
	end
end
