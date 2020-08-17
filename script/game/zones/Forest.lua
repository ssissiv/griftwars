local Forest = class( "Zone.Forest", Zone )

Forest.LOCATIONS =
{
	Location.Thicket, 2
}
Forest.ZONE_ADJACENCY =
{
	"Zone.City", 1,
	"Zone.Hills", 2,
	"Zone.Fields", 2,
}
Forest.ZONE_COLOUR = { 0, 200, 0 }

function Forest:OnWorldGenPass( pass )
	if self.name == nil then
		local adj = self.world.adjectives:PickName()
		self.name = loc.format( "The {1} Forest", adj )
	end

	if pass == 0 then
		local n = self.world:Random( 3 )
		if n == 1 then
			self:PopulateOrcs()
		elseif n == 3 then
			self:PopulateWolves()
		end
		return true
	end
end


function Forest:PopulateOrcs()
	local n = self.world:Random( #self.rooms )
	for i = 1, n do
		local orc = Agent.Orc()
		orc:WarpToLocation( self:RandomRoom() )
	end
end


function Forest:PopulateWolves()
	local n = self.world:Random( #self.rooms )
	for i = 1, n do
		local orc = Agent.GreyWolf()
		orc:WarpToLocation( self:RandomRoom() )
	end
end
