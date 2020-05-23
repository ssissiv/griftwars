
function Object:CalculateDC( value, verb )
	local acc = self:GetAspect( Aspect.ScalarCalculator )
	if acc then
		return acc:CalculateValue( CALC_EVENT.DC, value, verb )
	end
end
