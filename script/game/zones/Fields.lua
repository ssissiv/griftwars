local Fields = class( "Zone.Fields", Zone )

Fields.LOCATIONS =
{
	Location.OpenFields, 1,
}

Fields.ZONE_ADJACENCY =
{
	"Zone.Forest", 2,
	"Zone.Hills", 1,
	"Zone.City", 1,
}
Fields.ZONE_COLOUR = { 150, 210, 30 }


function Fields:OnWorldGenPass( pass )
	if self.name == nil then
		if self.world:Random() < 0.5 then
			local noun = self.world.nouns:PickName()
			self.name = loc.format( "The Fields of {1}", noun )
		else
			local adj = self.world.adjectives:PickName()
			self.name = loc.format( "The {1} Fields", adj )
		end
	end

	if pass == 0 then
		local room = self:RandomRoom()
		Object.LizardNest():WarpToLocation( room )
	end
end
