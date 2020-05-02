local City = class( "Zone.City", Zone )

City.LOCATIONS = { Location.CityDistrict1, Location.CityDistrict2, Location.Tavern, Location.Residence, Location.Shop }

function City:GenerateZone()
	local world = self.world

	self.name = world:GetAspect( Aspect.CityNamePool ):PickName()
	self.faction = world:CreateFaction( self.name )

	local depth = 0

	self.origin = Location.CityDistrict( self )
	self:SpawnLocation( self.origin, depth )

	local locations = { self.origin }
	local sanity = 0
	while #locations > 0 do
		local location = table.remove( locations, 1 )
		self:GeneratePortals( location, locations, location:GetZoneDepth() + 1 )
		sanity = sanity + 1
		assert( sanity < 99 )
	end
end

