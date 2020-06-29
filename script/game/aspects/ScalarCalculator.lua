local ScalarCalculator = class( "Aspect.ScalarCalculator", Aspect )

function ScalarCalculator:InitializeValue( value )
	self.value = value
	if self.sources then
		table.clear( self.sources )
	end
end

function ScalarCalculator:CalculateValueFromSources( event_name, ... )
	self.owner:BroadcastEvent( event_name, self, ... )

	local details
	if self.sources then
		details = table.concat( self.sources, "\n" )
	end

	return self.value, details
end

function ScalarCalculator:CalculateValue( event_name, value, ... )
	self:InitializeValue( value )
	return self:CalculateValueFromSources( event_name, ... )
end

function ScalarCalculator:AddSource( source )
	assert( type(source) == "string" )
	if self.sources == nil then
		self.sources = {}
	end
	table.insert( self.sources, source )
end

function ScalarCalculator:AddValue( mod, source )
	self.value = self.value + mod
	self:AddSource( loc.format( "{1%+d}: {2}", mod, source ))
end

function ScalarCalculator:SetValue( value, source )
	self.value = value
	self:AddSource( loc.format( "={1}: {2}", value, source ))
end

function ScalarCalculator:AppendValue( value, source )
	table.insert( self.value, value )
	self:AddSource( loc.format( "+{1}: {2}", value, source ))
end
