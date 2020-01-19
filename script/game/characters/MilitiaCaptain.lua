--[[
  A second in command in the militia.
  - Has command over MilitiaSoldiers, MilitiaQuarterMasters
  - Takes orders from MilitiaGeneral.

  - Values: Military, Power, Rumours, Defeating Enemies
  - Verbs: OrderAttackTeam, use Intel to invade enemy's Interaction??
  
--]]

---------------------------------------------------------------------

local MilitiaCaptain = class( "Agent.MilitiaCaptain", Agent )

function MilitiaCaptain:init()
	Agent.init( self )
	
	self.species = SPECIES.HUMAN
	
	self:GainAspect( Verb.Strategize( self ))
	self:GainAspect( Interaction.Befriend( CR1 ) )
	self:GainAspect( Interaction.Chat() )
end

function MilitiaCaptain:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Commander of the militia.", GENDER.MALE )
end

