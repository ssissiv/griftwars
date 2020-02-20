--------------------------------------------------------------
-- Marks a location used as a Tavern.
--
-- Locations have: Feature.Tavern (shop_owner: Agent)
-- Agents have: Job.Shopkeep (shop: Location)

local Tavern = class( "Feature.Tavern", Feature )

function Tavern:AssignBarkeep( agent )
	assert( is_instance( agent, Agent ))
	if agent ~= self.barkeep then
		assert( agent == nil or self.barkeep == nil )
		self.barkeep = agent
		local shopkeep = agent:GetAspect( Job.Barkeep )
		shopkeep:AssignTavern( self.location )
	end
end
 
function Tavern:SpawnBarkeep()
	local world = self:GetWorld()
	
	if self.name == nil then
		local adj = world.adjectives:PickName()
		local noun = world.nouns:PickName()
		local name = loc.format( "The {1} {2} Tavern", adj, noun )
		self.location:SetDetails( name )
	end

	local barkeep = Agent.Barkeep()
	barkeep:WarpToLocation( self.location )

	self:AssignBarkeep( barkeep )
	return barkeep
end


