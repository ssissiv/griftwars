local HealthValue = class( "Aspect.HealthValue", Aspect.StatValue )

function HealthValue:init( value, max_value )
	HealthValue._base.init( self, STAT.HEALTH, value, max_value )
end

function HealthValue:DeltaValue( value, max_value )
	HealthValue._base.DeltaValue( self, value, max_value )
	if self.value <= 0 then
		self.owner:Kill()
	end
end
