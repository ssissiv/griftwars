local Impass = class( "Aspect.Impass", Aspect )

function Impass:IsPassable( obj )
	if obj:GetAspect( Impass ) then
		return false -- could compare impass types
	end
	return true
end
