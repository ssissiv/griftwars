require "game/aspects/ScalarCalculator"

local DamageCalculator = class( "Aspect.DamageCalculator", Aspect.ScalarCalculator )

function DamageCalculator:InitializeValue( value )
	DamageCalculator._base.InitializeValue( self, value )
	self.piercing = 0
	self.req_piercing = 0
end

function DamageCalculator:ReqPiercing( source, source_desc )
	self.req_piercing = 1
	if self.piercing < self.req_piercing then
		self.value = 0
		self:AddSource( loc.format( "{1}: 0 (no piercing)", source_desc or source ))
	end
end

function DamageCalculator:SetPiercing( piercing, source, source_desc )
	if piercing > self.piercing then
		self.piercing = piercing
		self:AddSource( loc.format( "Piercing {1}: {2}", piercing, source_desc or source ))
	end
end
