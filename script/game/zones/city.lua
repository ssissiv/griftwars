local City = class( "Zone.City", Zone )

City.LOCATIONS = {
	[ Location.CityDistrict1 ] = 1,
	[ Location.CityDistrict2 ] = 1,
	[ Location.EmptyDistrict ] = 2,
	[ Location.Tavern ] = 1,
	[ Location.Residence ] = 1,
	[ Location.Shop ] = 1,
}

City.ZONE_ADJACENCY =
{
	["Zone.Forest"] = 1
}

City.ZONE_COLOUR = { 70, 70, 80 }

function City:OnGenerateZone()
	self.name = self.world:GetAspect( Aspect.CityNamePool ):PickName()
	self.faction = self.world:CreateFaction( self.name )
end

