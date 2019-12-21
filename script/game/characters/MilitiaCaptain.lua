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
	
	self:GainAspect( Aspect.Behaviour() ):RegisterVerbs{
		Verb.Strategize( self )
	}
	self:GainAspect( Interaction.Acquaint( CR1 ) )
	self:GainAspect( Interaction.Chat() )
end

function MilitiaCaptain:OnSpawn( world )
	Agent.OnSpawn( self, world )
	local name = world:GetAspect( Aspect.NamePool ):PickName()
	self:SetDetails( name, "Commander of the militia.", GENDER.MALE )
end

