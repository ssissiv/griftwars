local ScalarCalculator = class( "Aspect.ScalarCalculator", Aspect )

function ScalarCalculator:InitializeValue( value )
	self.value = value
	if self.sources then
		table.clear( self.sources )
	end
end

function ScalarCalculator:CalculateValueFromSources( owner, event_name, ... )
	assert( is_instance( owner, Entity ))
	owner:BroadcastEvent( event_name, self, ... )

	local details
	if self.sources then
		details = table.concat( self.sources, "\n" )
	end

	return self.value, details
end

function ScalarCalculator:CalculateValue( event_name, value, ... )
	self:InitializeValue( value )
	return self:CalculateValueFromSources( self.owner, event_name, ... )
end

function ScalarCalculator:AddSource( source )
	assert( type(source) == "string" )
	if self.sources == nil then
		self.sources = {}
	end
	table.insert( self.sources, source )
end

function ScalarCalculator:AddValue( mod, source, source_desc )
	self.value = self.value + mod
	self:AddSource( loc.format( "{1%+d}: {2}", mod, source_desc or source ))
end

function ScalarCalculator:MultiplyValue( mod, source, source_desc )
	self.value = self.value * mod
	self:AddSource( loc.format( "*{1}: {2}", mod, source_desc or source ))
end

function ScalarCalculator:SetValue( value, source, source_desc )
	self.value = value
	self:AddSource( loc.format( "={1}: {2}", value, source_desc or source ))
end

function ScalarCalculator:AppendValue( value, source, source_desc )
	table.insert( self.value, value )
	self:AddSource( loc.format( "+{1}: {2}", value, source_desc or source ))
end
