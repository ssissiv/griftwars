local RingOfSlaying = class( "Object.RingOfSlaying", Object )

function RingOfSlaying:init()
	Object.init( self )
	self.value = 150
	self:GainAspect( Aspect.Wearable( EQ_SLOT.RING ))
	self:GainAspect( Aspect.Carryable() )
end

function RingOfSlaying:GetName()
	return "ring of slaying"
end
