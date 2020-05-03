local Forest = class( "Zone.Forest", Zone )

Forest.LOCATIONS =
{
	[ Location.Thicket ] = 2
}
Forest.ZONE_ADJACENCY =
{
	["Zone.City"] = 1,
}
Forest.ZONE_COLOUR = { 0, 200, 0 }

function Forest:OnWorldGenPass( pass )
	if self.name == nil then
		local adj = self.world.adjectives:PickName()
		self.name = loc.format( "The {1} Forest", adj )
	end

	if pass == 0 then
		self:PopulateOrcs()
		return true
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
