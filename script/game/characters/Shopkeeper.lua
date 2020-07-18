--[[
Shopkeeps maintain a stock of items, and sells them in a store.
--]]

local Shopkeeper = class( "Agent.Shopkeeper", Agent )
Shopkeeper.MAP_CHAR = "S"
Shopkeeper.unfamiliar_desc = "shopkeeper"

function Shopkeeper:init()
	Agent.init( self )

	self:MakeHuman()

	self.job = self:GainAspect( Job.ManageShop( self ) )
end

function Shopkeeper:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
end
