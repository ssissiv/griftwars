--[[
	Barkeeper serves drinks.
--]]

local Barkeep = class( "Agent.Barkeep", Agent )

Barkeep.MAP_CHAR = "B"

function Barkeep:init()
	Agent.init( self )

	self:MakeHuman()

	self.job = self:GainAspect( Job.Barkeep( self ) )

	self:GainAspect( Aspect.Behaviour() )
end

function Barkeep:GetTitle()
	return "Barkeep"
end
