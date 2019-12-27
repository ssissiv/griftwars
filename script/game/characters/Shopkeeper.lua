local Assistant = class( "Job.Assistant", Job )

Assistant.salary = 5

function Assistant:OnInit()
	self:SetShiftHours( 8, 16 )
end

function Assistant:GetLocation()
	return self.employer:GetLocation()
end

function Assistant:GetName()
	return "Assistant"
end

-------------------------------------------------------------------------------------

--[[
Shopkeeps maintain a stock of items, and sells them in a store.
--]]

local Shopkeeper = class( "Agent.Shopkeeper", Agent )

function Shopkeeper:init()
	Agent.init( self )
	local shop = self:GainAspect( Aspect.Shopkeep() )
	shop:AddShopItem( Object.Jerky() )

	self.job = Job.Assistant( self )
	self:GainAspect( Interaction.OfferJob( self.job ))
end

function Shopkeeper:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )

	if math.random() < 0.5 then
		local assistant = Agent.Citizen()
		world:SpawnAgent( assistant )
		assistant:GainAspect( self.job )
		DBG(assistant)
	end
end
