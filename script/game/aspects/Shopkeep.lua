
--------------------------------------------------------------

local Shopkeep = class( "Aspect.Shopkeep", Aspect )

function Shopkeep:init()
	self:RegisterHandler( AGENT_EVENT.FOCUS_CHANGED, self.OnFocusChanged )
end

function Shopkeep:OnFocusChanged( prev_focus, focus )
	if is_instance( focus, Agent ) then
		Msg:Speak( "Welcome. Good deals today.", self.owner )
	end
end

function Shopkeep:SellItem( item )
end

function Shopkeep:BuyItem( item )
end
