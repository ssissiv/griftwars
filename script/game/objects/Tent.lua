local Tent = class( "Object.Tent", Object )
Tent.name = "Tent"
Tent.image = assets.TILE_IMG.TENT

function Tent:init()
	Object.init( self )
	self.portal = self:GainAspect( Aspect.Portal() )
end

function Tent:SpawnInterior()
	assert( not self.portal:GetDest() )

	local interior = Location.TentInterior()
	self.world:SpawnLocation( interior )

	local other_portal = interior:FindPortalWithTag( "tent" )
	self.portal:ConnectPortal( other_portal )

	return interior
end

function Tent:GetDest()
	return self.portal:GetDest()
end
