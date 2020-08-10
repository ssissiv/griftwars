local HoldObject = class( "Verb.HoldObject", Verb )

function HoldObject:init( actor, obj )
	Verb.init( self, actor )
	assert( is_instance( obj, Object ))
	self.obj = obj
end

function HoldObject:GetActDesc()
	local wearable = self.obj:GetAspect( Aspect.Wearable )
	if wearable and wearable:IsEquipped( EQ_SLOT.HELD ) then
		return loc.format( "Release {1}", tostring(self.obj) )
	elseif wearable and not wearable:IsEquipped() then
		return loc.format( "Hold {1}", tostring(self.obj) )
	end
end

function HoldObject:CanInteract()
	local wearable = self.obj:GetAspect( Aspect.Wearable )
	if not wearable or (wearable:IsEquipped() and not wearable:IsEquipped( EQ_SLOT.HELD )) then
		return false --, already held
	end
	return Verb.CanInteract( self )
end

function HoldObject:Interact()
	local actor, obj = self.actor, self.obj
	local wearable = obj:GetAspect( Aspect.Wearable )
	if not wearable then
		wearable = obj:GainAspect( Aspect.Wearable( EQ_SLOT.HELD ))
	end
	if wearable:IsEquipped() then
		Msg:EchoTo( actor, "You release {1}.", obj )
		wearable:Unequip()
	else
		Msg:EchoTo( actor, "You hold {1}.", obj )
		wearable:Equip()
	end
end
