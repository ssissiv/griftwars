local Forest = class( "WorldGen.Forest", Zone )

function Forest:init( worldgen, size )
	Zone.init( self, worldgen )
	self.size = size or 1
end

function Forest:GenerateZone()
	local world = self.world

	local adj = world.adjectives:PickName()
	self.name = loc.format( "The {1} Forest", adj )

	self.origin = Location.Thicket( self )
	self:SpawnLocation( self.origin )

	self.thickets = { self.origin }

	local locations = { self.origin }
	local count = 0
	while #locations > 0 and count < 8 do
		local location = table.remove( locations, 1 )
		self:GeneratePortals( location, locations )
		table.insert( self.districts, location )
		count = count + 1
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

function Forest:RandomRoom()
	return self.worldgen:ArrayPick( self.thickets )
end

