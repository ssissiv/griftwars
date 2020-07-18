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
	
	self:GainAspect( Verb.Strategize())
	self:GainAspect( Skill.Fighting():SetSkillRank( 5 ))
	self:GainAspect( Aspect.Intel())
end

function Commander:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "The commander of the militia.", GENDER.MALE )
end

function Commander:OnAgentEvent( event_name, agent, ... )
	if event_name == AGENT_EVENT.STRATEGIZE then
		local target = ...
		local waypoint = Waypoint()
		waypoint:TrackLocation( target )
		
		-- Assign patrols to this waypoint.
		-- for i, job in ipairs( self.patrols ) do
		-- 	job:SetWaypoint( waypoint )
		-- end
	end
end

-- function Captain:Recruit( job )
-- 	if not job.owner or not job.owner:IsSpawned() then
-- 		local recruit = self.world:RequireAgent(
-- 			function()
-- 				local fighter = Agent.Fighter()
-- 				if self:HasAspect( Aspect.FactionMember ) then
-- 					self:GetAspect( Aspect.FactionMember ):AssignFaction( fighter )
-- 				end
-- 				return self.world:SpawnAgent( fighter, self.location )
-- 			end )
-- 			-- function( agent )
-- 			-- 	return not agent:IsPlayer() and
-- 			-- 			not agent:IsEnemy( self ) and
-- 			-- 			agent:CanLearnSkill( Skill.Fighting ) and
-- 			-- 			not agent:IsEmployed()
-- 			-- end )

-- 		recruit:GainAspect( job )
-- 	end
-- end

-- function Captain:RecruitAll()
-- 	for i, job in ipairs( self.patrols ) do
-- 		self:Recruit( job )
-- 	end
-- end

