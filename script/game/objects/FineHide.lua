local FineHide = class( "Object.FineHide", Object )
FineHide.name = "Fine Hide"
FineHide.value = 10

function FineHide:init()
	Object.init( self )

	self:GainAspect( Aspect.Carryable() )
end