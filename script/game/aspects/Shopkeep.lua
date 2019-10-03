
--------------------------------------------------------------

local Shopkeep = class( "Aspect.Shopkeep", Aspect )

function Shopkeep:init()
	self:RegisterHandler( AGENT_EVENT.FOCUS_CHANGED, self.OnFocusChanged )
end

function Shopkeep:OnGainAspect( owner )
	Aspect.OnGainAspect( self, owner )
	owner:GainAspect( Interaction.BuyFromShop() )
end

function Shopkeep:OnFocusChanged( event_name, agent, prev_focus, focus )
	if agent == self.owner then
		Msg:Speak( "Welcome. Good deals today.", self.owner )
		if focus:Acquaint( self.owner ) then
			Msg:Speak( "I'm {1.Id}.", self.owner )
		end
	end
end

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

