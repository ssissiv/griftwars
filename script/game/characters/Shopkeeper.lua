--[[
Shopkeeps maintain a stock of items, and sells them in a store.
--]]

local Shopkeeper = class( "Agent.Shopkeeper", Agent )

function Shopkeeper:init()
	Agent.init( self )


	self.job = self:GainAspect( Job.Shopkeep( self ) )

	self.assistant_job = Job.Assistant( self )
	self:GainAspect( Interaction.OfferJob( self.assistant_job ))

	self:GainAspect( Aspect.Behaviour() ):RegisterVerbs{
		Verb.ManageFatigue( self ),
		self.job
	}
end

function Shopkeeper:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Rough looking fellow in a coat of multiple pockets.", GENDER.MALE )

	if math.random() < 0.5 then
		local assistant = Agent.Citizen()
		world:SpawnAgent( assistant )
		assistant:GainAspect( self.assistant_job )
		assistant:GetAspect( Aspect.Behaviour ):RegisterVerb( self.assistant_job )
	end
end
