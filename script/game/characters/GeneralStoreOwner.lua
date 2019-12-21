--[[
Shopkeeps maintain a stock of items, and sells them in a store.
--]]

local GeneralStoreOwner = class( "Agent.GeneralStoreOwner", Agent )

function GeneralStoreOwner:init()
	Agent.init( self )
	local shop = self:GainAspect( Aspect.Shopkeep() )
	shop:AddShopItem( Object.Jerky() )
end

function GeneralStoreOwner:OnSpawn( world )
	Agent.OnSpawn( self, world )
	local name = world:GetAspect( Aspect.NamePool ):PickName()
	self:SetDetails( name, "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
end
