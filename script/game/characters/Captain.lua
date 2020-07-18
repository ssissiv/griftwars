--[[
  A second in command in the militia.
  - Has command over MilitiaSoldiers, MilitiaQuarterMasters
  - Takes orders from MilitiaGeneral.

  - Values: Military, Power, Rumours, Defeating Enemies
  - Verbs: OrderAttackTeam, use Intel to invade enemy's Interaction??
  
--]]

---------------------------------------------------------------------

local Captain = class( "Agent.Captain", Agent )

Captain.MAP_CHAR = "c"
Captain.unfamiliar_desc = "captain"
Captain.image = assets.TILE_IMG.CAPTAIN
Captain.max_health = 40

function Captain:init()
	Agent.init( self )
	
	Agent.MakeHuman( self )
	
	self:GainAspect( Skill.Fighting():SetSkillRank( 3 ))
	self:GainAspect( Aspect.Intel())
	
	self:EquipItem( Armour.ChainMail() )
	self:EquipItem( Weapon.LongSword() )
end

function Captain:OnSpawn( world )
	Agent.OnSpawn( self, world )
end
