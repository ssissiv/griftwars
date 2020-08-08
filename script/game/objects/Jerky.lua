local Jerky = class( "Object.Jerky", Object )

function Jerky:init()
	Object.init( self )
	self:GainAspect( Aspect.Carryable() )
	self:GainAspect( Aspect.Edible() ):SetEnergyGain( 12 )
end

function Jerky:GetName()
	return "Jerky"
end

function Jerky:GetValue()
	return 3
end
