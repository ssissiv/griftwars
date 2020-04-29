local Forest = class( "Zone.Forest", Zone )

Forest.LOCATIONS = { Location.Thicket }

function Forest:GenerateZone()
	local world = self.world

	local adj = world.adjectives:PickName()
	self.name = loc.format( "The {1} Forest", adj )

	local depth = 0

	if self.origin == nil then
		self.origin = Location.Thicket( self )
		self:SpawnLocation( self.origin, depth )
	end

	print( self.origin )

	local locations = { self.origin }
	while #locations > 0 and locations[1]:GetZoneDepth() < self.max_depth do
		local location = table.remove( locations, 1 )
		self:GeneratePortals( location, locations, location:GetZoneDepth() + 1 )
	end
end


function Forest:PopulateOrcs()
	local n = self.worldgen:Random( 3 )
	if n == 1 then
		-- Some Orcs
		n = math.ceil( #self.rooms / 5 )
	elseif n == 2 then
		-- LOTS of Orcs!
		n = math.ceil( #self.rooms / 3 )
	else
		-- No orcs!
		n = 0
	end
	for i = 1, n do
		local orc = Agent.Orc()
		orc:WarpToLocation( self:RandomRoom() )
	end
end
