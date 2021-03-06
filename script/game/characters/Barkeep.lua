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
	self:DeltaLevel( math.random( 3, 8 ))
end
