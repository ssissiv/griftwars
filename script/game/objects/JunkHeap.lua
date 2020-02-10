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

function JunkHeap:OnSpawn( world )
	JunkHeap._base.OnSpawn( self, world )
	world:SchedulePeriodicFunction( ONE_HOUR, self.RefreshJunk, self )
end

function JunkHeap:RefreshJunk()
	local quality = table.arraypick{ QUALITY.POOR, QUALITY.AVERAGE, QUALITY.GOOD }
	self:GetAspect( Aspect.ScroungeTarget ):SetQuality( quality )
end


function JunkHeap:GetName()
	return "Junk Heap"
end

