local Hills = class( "Zone.Hills", Zone )

Hills.LOCATIONS =
{
	Location.OpenHills, 1,
	Location.Cave, 1,
	Location.BottomOfWell, 1,
}

Hills.ZONE_ADJACENCY =
{
	"Zone.Forest", 2,
	"Zone.Fields", 2,
	"Zone.City", 1,
}
Hills.ZONE_COLOUR = { 100, 150, 0 }


function Hills:OnWorldGenPass( pass )
	if self.name == nil then
		local adj = self.world.adjectives:PickName()
		self.name = loc.format( "The {1} Hills", adj )
	end

	Zone.OnWorldGenPass( self, pass )
end
