local JunkHeap = class( "Object.JunkHeap", Object )

JunkHeap.MAP_CHAR = "%"

function JunkHeap:OnSpawn( world )
	JunkHeap._base.OnSpawn( self, world )

	self.rng = self:GainAspect( Aspect.Rng())
	self:GainAspect( Aspect.Inventory() )
	self:GainAspect( Aspect.ScroungeTarget())
	self:GainAspect( Aspect.Impass( IMPASS.ALL ) )

	self:RefreshJunk()

	world:SchedulePeriodicFunction( ONE_HOUR, self.RefreshJunk, self )
end

function JunkHeap:RefreshJunk()
	self:GetAspect( Aspect.Inventory ):ClearItems()
	
	if self.rng:Random() < 0.5 then
		self:GetAspect( Aspect.ScroungeTarget ):SetLootTable( LOOT_JUNK_T1 )
	elseif self.rng:Random() < 0.5 then
		self:GetAspect( Aspect.ScroungeTarget ):SetLootTable( LOOT_JUNK_T2 )
	else
		self:GetAspect( Aspect.ScroungeTarget ):SetLootTable( LOOT_JUNK_T3 )
	end
end


function JunkHeap:GetName()
	return "Junk Heap"
end

