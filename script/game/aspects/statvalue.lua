local StatValue = class( "Aspect.StatValue", Aspect )

function StatValue:init( stat )
	self.stat = stat
	self.value = 0
end

function StatValue:GetID()
	return self.stat
end

function StatValue:DeltaValue( delta )
	self.value = self.value + delta
end

function StatValue:GetValue()
	return self.value
end
