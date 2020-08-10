local Creds = class( "Object.Creds", Object )

function Creds:init( value )
	Object.init( self )
	assert( value == nil or type(value) == "number" )
	self.value = value

	self:GainAspect( Aspect.Carryable() )
	self:GainAspect( Aspect.Currency() )
end

function Creds:GetName()
	return loc.format( "{1} {1*Credit|Credits}", self.value )
end

function Creds:__tostring()
	return string.format( "[%s: %d]", self:GetName(), self.value )
end