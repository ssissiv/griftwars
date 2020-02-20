--------------------------------------------------------------
-- Agent-side model of the Shopkeeper job.
-- Links to: Feature.Shop (Location-side model of this job)
-- Owner gains: Interaction.BuyFromShop (so that agents can interact with this shopkeeper)
-- 
local Shopkeep = class( "Job.Shopkeep", Job )

Shopkeep.salary = 30

function Shopkeep:OnInit()
	self:RegisterHandler( AGENT_EVENT.LOCATION_CHANGED, self.OnLocationChanged )
	self:SetShiftHours( 8, 18 )
end

function Shopkeep:GetName()
	return loc.format( "Shopkeeper at the {1}", self.shop:GetTitle() )
end

function Shopkeep:GetLocation()
	return self.shop
end

function Shopkeep:AssignShop( shop )
	assert( shop == nil or is_instance( shop, Location ))
	if shop ~= self.shop then
		self.shop = shop
		if shop then
			shop:GetAspect( Feature.Shop ):AssignShopOwner( self.owner )
		end
	end
end

function Shopkeep:OnSpawn( world )
	Job.OnSpawn( self, world )

	-- People can buy from us.
	self.owner:GainAspect( Interaction.BuyFromShop() )

	-- Sometimes we have assistants.
	if math.random() < 0.5 then
		self.assistant_job = Job.Assistant( self.owner )
		self.owner:GainAspect( Interaction.OfferJob( self.assistant_job ))

		if math.random() < 0.5 then
			local assistant = Agent.Citizen()
			world:SpawnAgent( assistant )
			assistant:GainAspect( self.assistant_job )
		end
	end
end

function Shopkeep:OnLocationChanged( event_name, agent, prev_location, location )
	if prev_location then
		prev_location:RemoveListener( self )
	end
	if location then
		location:ListenForAny( self, self.OnLocationEvent )
	end
end

function Shopkeep:IsAssistant( agent )
	if self.assistant_job then
		return self.assistant_job.owner == agent
	end
	return false
end

function Shopkeep:OnLocationEvent( event_name, location, ... )
	if event_name == LOCATION_EVENT.AGENT_ADDED and location == self.owner:GetLocation() and location == self.shop then
		local agent = ...
		if not self:IsAssistant( agent ) then
			if agent:Acquaint( self.owner ) then
				Msg:Speak( self.owner, "Welcome, welcome! I'm {1.Id}.", self.owner:LocTable( agent ) )
			else
				Msg:Speak( self.owner, "Good deals today." )
			end
		end
	end
end

function Shopkeep:AddShopItem( item )
	self.owner:GetInventory():AddItem( item )
end

--------------------------------------------------------------

function Shopkeep:SellToBuyer( item, buyer )
	local cost = self:GetBuyCost( item, buyer )
	buyer:DeltaMoney( -cost )

	local clone = item:Clone()
	buyer:GetInventory():AddItem( clone )

	Msg:Echo( buyer, "You bought a {1} from {2}.", item:GetName(), self.owner )
	Msg:Echo( self.owner, "You sell a {1} to {2}.", item, buyer )
end

function Shopkeep:GetBuyCost( item, buyer )
	return item:GetValue()
end

function Shopkeep:BuyFromSeller( item, seller )
	seller:GetInventory():RemoveItem( item )
	self.owner:GetInventory():AddItem( item )
	Msg:Echo( self.owner, "You bought a {1} from {2}.", item:GetName(), seller )
	Msg:Echo( seller, "You sell a {1} to {2}.", item, self.owner )
end

