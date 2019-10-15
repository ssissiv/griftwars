--[[
Shopkeeps maintain a stock of items, and sells them in a store.
--]]

local Behaviour = class( "Behaviour.ManageStore", Aspect.Behaviour )

Behaviour.event_handlers =
{
	[ AGENT_EVENT.COLLECT_VERBS ] = function( self, event_name, agent, verbs )
		verbs:AddVerb( Verb.Idle() )
	end
}


function Agent.GeneralStoreOwner()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
	ch:GainAspect( Behaviour() )
	local shop = ch:GainAspect( Aspect.Shopkeep() )
	shop:AddShopItem( Object.Jerky() )
 	return ch
end

