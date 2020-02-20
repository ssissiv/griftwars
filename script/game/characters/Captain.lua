--[[
  A second in command in the militia.
  - Has command over MilitiaSoldiers, MilitiaQuarterMasters
  - Takes orders from MilitiaGeneral.

  - Values: Military, Power, Rumours, Defeating Enemies
  - Verbs: OrderAttackTeam, use Intel to invade enemy's Interaction??
  
--]]

---------------------------------------------------------------------

local Captain = class( "Agent.Captain", Agent )

function Captain:init()
	Agent.init( self )
	
	self.species = SPECIES.HUMAN
	
	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.Strategize( self ))
	self:GainAspect( Interaction.Befriend( CR1 ) )
	self:GainAspect( Interaction.Chat() )
end

function Captain:GetTitle()
	return "Captain"
end

function Captain:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A captain of the militia.", GENDER.MALE )
end

