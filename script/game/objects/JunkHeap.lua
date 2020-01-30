local JunkHeap = class( "Object.JunkHeap", Object )

function JunkHeap:init()
	Object.init( self )
	self:GainAspect( Aspect.ScroungeTarget() )
end

function JunkHeap:GetName()
	return "Junk Heap"
end

