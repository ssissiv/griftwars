--[[
  A second in command in the militia.
  - Has command over MilitiaSoldiers, MilitiaQuarterMasters
  - Takes orders from MilitiaGeneral.

  - Values: Military, Power, Rumours, Defeating Enemies
  - Verbs: OrderAttackTeam, use Intel to invade enemy's Interaction??
  
--]]

---------------------------------------------------------------------

local Commander = class( "Agent.Commander", Agent )

Commander.MAP_CHAR = "C"
Commander.unfamiliar_desc = "commander"

function Commander:init()
	Agent.init( self )
	
	Agent.MakeHuman( self )
	
	self:GainAspect( Skill.Fighting():SetSkillRank( 5 ))
	self:GainAspect( Aspect.Intel())

	self:EquipItem( Armour.ChainMail() )
	self:EquipItem( Weapon.LongSword() )
end

function Commander:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "The commander of the militia.", GENDER.MALE )
end


