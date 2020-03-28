--[[
Shopkeeps maintain a stock of items, and sells them in a store.
--]]

local Shopkeeper = class( "Agent.Shopkeeper", Agent )

function Shopkeeper:init()
	Agent.init( self )

	self:MakeHuman()

	self.job = self:GainAspect( Job.Shopkeep( self ) )

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))
end

function Shopkeeper:GetTitle()
	return "Shopkeeper"
end


function Shopkeeper:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )
end
