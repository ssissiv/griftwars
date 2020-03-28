--[[
	Barkeeper serves drinks.
--]]

local Barkeep = class( "Agent.Barkeep", Agent )

function Barkeep:init()
	Agent.init( self )

	self:MakeHuman()

	self.job = self:GainAspect( Job.Barkeep( self ) )

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))
end

function Barkeep:GetTitle()
	return "Barkeep"
end
