local RingOfSlaying = class( "Object.RingOfSlaying", Object )

RingOfSlaying.EQ_SLOT = EQ_SLOT.RING

function RingOfSlaying:GetName()
	return "ring of slaying"
end

function RingOfSlaying:GetValue()
	return 150
end
