local Berries = class( "Object.Berries", Object )

function Berries:init()
	Object.init( self )
	self:GainAspect( Aspect.Carryable() )
	self:GainAspect( Aspect.Edible():SetEnergyGain( 4 ) )
end

function Berries:GetName()
	return "berries"
end

function Berries:GetValue()
	return 1
end
