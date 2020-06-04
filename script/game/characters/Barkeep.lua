--[[
	Barkeeper serves drinks.
--]]

local Barkeep = class( "Agent.Barkeep", Agent )

Barkeep.MAP_CHAR = "B"
Barkeep.unfamiliar_desc = "barkeep"

function Barkeep:init()
	Agent.init( self )

	self:MakeHuman()

	self.job = self:GainAspect( Job.Barkeep( self ) )

	self:GainAspect( Aspect.Behaviour() )
end
