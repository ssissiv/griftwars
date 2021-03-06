--------------------------------------------------------------
-- Agent-side model of the Shopkeeper job.
-- Links to: Feature.Shop (Location-side model of this job)
-- Owner gains: Interaction.BuyFromShop (so that agents can interact with this shopkeeper)
-- 
local ManageShop = class( "Job.ManageShop", Job )

ManageShop.salary = 30

function ManageShop:OnInit()
	self:SetShiftHours( 8, 18 )
end

function ManageShop:GetName()
	return loc.format( "Shopkeeper at the {1}", self.shop:GetLocation():GetTitle() )
end

function ManageShop:GetWaypoint()
	return self.shop:GetLocation():GetWaypointByTag( WAYPOINT.KEEPER )
end

function ManageShop:AssignShop( shop )
	assert( shop == nil or is_instance( shop, Feature.Shop ))
	if shop ~= self.shop then
		self.shop = shop
		if shop then
			shop:AssignShopOwner( self.owner )
		end
	end
end

function ManageShop:OnSpawn( world )
	Job.OnSpawn( self, world )

	-- Sometimes we have assistants.
	if world:Random() < 0.5 then
		self.assistant_job = Job.Assistant( self.owner, self )
		self.owner:GainAspect( Interaction.OfferJob( self.assistant_job ))
	end
end

function ManageShop:OnLocationChanged( prev_location, location )
	if prev_location then
		prev_location:RemoveListener( self )
	end
	if location then
		location:ListenForAny( self, self.OnLocationEvent )
	end
end

function ManageShop:TrySpawnAssistant()
	if self.assistant_job and not self.assistant_job.owner then
		-- TODO: probably temp.  Just spawn a citizen.
		local assistant = Agent.Citizen()
		assistant:GainAspect( self.assistant_job )
		return assistant
	end
end

function ManageShop:IsAssistant( agent )
	if self.assistant_job then
		return self.assistant_job.owner == agent
	end
	return false
end

function ManageShop:IsCustomer( agent )
	if self:IsAssistant( agent ) then
		return false
	end
	if agent:IsEnemy( self.owner ) then
		return false
	end
	return true
end

function ManageShop:OnLocationEvent( event_name, location, ... )
	if event_name == LOCATION_EVENT.AGENT_ADDED and location == self.owner:GetLocation() and location == self.shop:GetLocation() then
		local agent = ...
		if self:IsCustomer( agent ) then
			if agent:Acquaint( self.owner ) then
				Msg:Speak( self.owner, "Welcome, welcome! I'm {1.Id}.", self.owner:LocTable( agent ) )
			else
				Msg:Speak( self.owner, "Good deals today." )
			end
		end
	end
end

function ManageShop:CollectVerbs( verbs, actor, obj )
	if actor ~= self.owner and self.owner == obj then
		verbs:AddVerb( Verb.BuyFromShop( actor, self.owner, self.shop ) )
	end
	Job.CollectVerbs( self, verbs, actor, obj )
end

--------------------------------------------------------------

function ManageShop:SellToBuyer( item, buyer )
	local cost = self:GetBuyCost( item, buyer )
	buyer:GetInventory():TransferMoney( cost, self.owner )

	local clone = item:Clone()
	buyer:GetInventory():AddItem( clone )

	Msg:EchoTo( buyer, "You bought a {1} from {2}.", item:GetName(), self.owner )
	Msg:EchoTo( self.owner, "You sell a {1} to {2}.", item, buyer )
end

function ManageShop:CanBuy( obj, buyer )
	local cost = self:GetBuyCost( obj, buyer )
	if cost > buyer:GetInventory():GetMoney() then
		return false, "Can't afford"
	end

	local ok, reason = buyer:CanCarry( obj )
	if not ok then
		return false, reason
	end

	return true
end

-- Buying FROM us.
function ManageShop:GetBuyCost( item, buyer )
	if item.GetModifiedValue then
		return item:GetModifiedValue()
	else
		return item:GetValue()
	end
end

-- Selling TO us.
function ManageShop:GetSellCost( item, seller )
	return math.floor( self:GetBuyCost( item, seller ) * 0.8 )
end

function ManageShop:BuyFromSeller( item, seller )
	seller:GetInventory():TransferItem( item, self.owner:GetInventory() )
	Msg:EchoTo( self.owner, "You bought a {1} from {2}.", item:GetName(), seller )
	Msg:EchoTo( seller, "You sell a {1} to {2}.", item, self.owner )
	local cost = self:GetSellCost( item, seller )
	self.owner:GetInventory():TransferMoney( cost, seller )
end

