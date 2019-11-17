
--------------------------------------------------------------

local Shopkeep = class( "Aspect.Shopkeep", Aspect )

function Shopkeep:init()
	self:RegisterHandler( AGENT_EVENT.LOCATION_CHANGED, self.OnLocationChanged )
	self:RegisterHandler( AGENT_EVENT.CALC_AGENDA, self.OnCalculateAgenda )
end

function Shopkeep:AssignShop( shop )
	assert( shop == nil or is_instance( shop, Location ))
	self.shop = shop
end

function Shopkeep:OnGainAspect( owner )
	Aspect.OnGainAspect( self, owner )
	owner:GainAspect( Interaction.BuyFromShop() )
end

function Shopkeep:OnCalculateAgenda( event_name, agent, agenda )
	agenda:ScheduleTaskForAgenda( Verb.Travel( agent, self.shop ), 6, 17, self )
end

function Shopkeep:OnLocationChanged( event_name, agent, prev_location, location )
	if prev_location then
		prev_location:RemoveListener( self )
	end
	if location then
		location:ListenForAny( self, self.OnLocationEvent )
	end
end

function Shopkeep:OnLocationEvent( event_name, location, ... )
	if event_name == LOCATION_EVENT.AGENT_ADDED and location == self.owner:GetLocation() and location == self.shop then
		local agent = ...
		if agent:Acquaint( self.owner ) then
			Msg:Speak( self.owner, "Welcome, welcome! I'm {1.Id}." )
		else
			Msg:Speak( self.owner, "Good deals today." )
		end
	end
end

function Shopkeep:AddShopItem( item )
	self.owner:GetInventory():AddItem( item )
end

--------------------------------------------------------------

function Shopkeep:SellToBuyer( item, buyer )
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

