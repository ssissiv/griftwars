local City = class( "Zone.City", Zone )

City.LOCATIONS = { Location.CityDistrict1, Location.CityDistrict2, Location.Tavern, Location.Residence, Location.Shop }

function City:GenerateZone()
	local world = self.world

	self.name = world:GetAspect( Aspect.CityNamePool ):PickName()
	self.faction = world:CreateFaction( self.name )

	local depth = 0

	self.origin = Location.CityDistrict( self )
	self:SpawnLocation( self.origin, depth )
	self.origin:SetCoordinate( 0, 0 )

	local locations = { self.origin }
	while #locations > 0 do
		local location = table.remove( locations, 1 )
		self:GeneratePortals( location, locations, location:GetZoneDepth() + 1 )
	end
end

