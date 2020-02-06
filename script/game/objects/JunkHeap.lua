local JunkHeap = class( "Object.JunkHeap", Object )

function JunkHeap:init()
	Object.init( self )

	if math.random() < 0.5 then
		self:GainAspect( Aspect.ScroungeTarget( QUALITY.POOR ))
	elseif math.random() < 0.5 then
		self:GainAspect( Aspect.ScroungeTarget( QUALITY.AVERAGE ))
	else
		self:GainAspect( Aspect.ScroungeTarget( QUALITY.GOOD ))
	end
end

function JunkHeap:GetName()
	return "Junk Heap"
end

