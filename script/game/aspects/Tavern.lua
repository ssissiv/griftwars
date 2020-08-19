--------------------------------------------------------------
-- Marks a location used as a Tavern.
--
-- Locations have: Feature.Tavern (shop_owner: Agent)
-- Agents have: Job.ManageShop (shop: Location)

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
	
	local barkeep = Agent.Barkeep()
	barkeep:WarpToLocationRegion( self.location, RGN_SERVING_AREA )
	assert( barkeep:GetTile():GetRegionID() == RGN_SERVING_AREA )

	self:AssignBarkeep( barkeep )
	return barkeep
end


