local ScalarCalculator = class( "Aspect.ScalarCalculator", Aspect )

function ScalarCalculator:CalculateValue( event_name, value, ... )
	self.value = value
	if self.sources then
		table.clear( self.sources )
	end

	self.owner:BroadcastEvent( event_name, self, ... )

	return self.value
end

function ScalarCalculator:AddSource( source )
	if self.sources == nil then
		self.sources = {}
	end
	table.insert( self.sources, source )
end

function ScalarCalculator:AddValue( mod, source )
	self.value = self.value + mod
	self:AddSource( source )
end

function ScalarCalculator:SetValue( value, source )
	self.value = value
	self:AddSource( source )
end
