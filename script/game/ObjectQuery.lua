
function Object:CalculateDC( value, verb )
	local acc = self:GetAspect( Aspect.ScalarCalculator )
	if acc == nil then
		acc = self:GainAspect( Aspect.ScalarCalculator() )
	end
	return acc:CalculateValue( CALC_EVENT.DC, value, verb )
end
