local City = class( "WorldGen.City", Zone )

function City:init( worldgen, sz )
	assert( sz )
	Zone.init( self, worldgen )
	self.size = sz or 1
end

function City:GenerateZone()
	local world = self.world

	self.name = world:GetAspect( Aspect.CityNamePool ):PickName()
	self.faction = world:CreateFaction( self.name )

	self.origin = Location.CityDistrict( self )
	self:SpawnLocation( self.origin )

	self.districts = { self.origin }

	local locations = { self.origin }
	local count = 0
	while #locations > 0 and count < 8 do
		local location = table.remove( locations, 1 )
		self:GeneratePortals( location, locations )
		table.insert( self.districts, location )
		count = count + 1
	end
end

function City:RandomRoad()
	return table.arraypick( self.districts )
end

