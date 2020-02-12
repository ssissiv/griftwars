--[[
	Barkeeper serves drinks.
--]]

local Barkeep = class( "Agent.Barkeep", Agent )

function Barkeep:init()
	Agent.init( self )

	self.species = SPECIES.HUMAN
	self.gender = GENDER.MALE

	self.job = self:GainAspect( Job.Barkeep( self ) )

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))
end

function Barkeep:GetTitle()
	return "Barkeep"
end
