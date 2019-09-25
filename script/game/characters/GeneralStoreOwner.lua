--[[
Shopkeeps maintain a stock of items, and sells them in a store.
--]]

function Agent.GeneralStoreOwner()
	local ch = Agent()
	ch:SetDetails( table.arraypick( CHARACTER_NAMES ), "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
	-- ch:GainAspect( Aspect.Behaviour() )
	ch:GainAspect( Aspect.Shopkeep() )
 	return ch
end

