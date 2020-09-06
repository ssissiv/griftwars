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
 
function Tavern:IsOpenForBusiness()
	if self.barkeep == nil or self.barkeep:IsDead() then
		return false, "No proprietor"
	end

	local job = self.barkeep:GetAspect( Job.Barkeep )
	if not job then
		return false, "No job"
	end

	if not job:IsTimeForShift( self:Now() ) then
		return false, "Not time for shift"
	end

	return true
end

function Tavern:SpawnBarkeep()
	local world = self:GetWorld()
	
	local barkeep = Agent.Barkeep()
	barkeep:WarpToLocationRegion( self.location, RGN_SERVING_AREA )
	assert( barkeep:GetTile():GetRegionID() == RGN_SERVING_AREA )

	self:AssignBarkeep( barkeep )
	return barkeep
end


