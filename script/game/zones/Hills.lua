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

	if pass == 0 then
		self:PopulateCaves()
		return true
	end
end

function Hills:PopulateCaves()
	for i, room in ipairs( self.rooms ) do
		if is_instance( room, Location.Cave ) then
			local bear = Agent.BrownBear()
			bear:WarpToLocation( room )
			room:GetAspect( Feature.Home ):AddResident( bear )
		end
	end
end