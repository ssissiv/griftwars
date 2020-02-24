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

	self.patrols = {}
	for i = 1, 3 do
		self.patrols[i] = Job.Patrol( self )
	end
end

function Captain:GetTitle()
	return "Captain"
end

function Captain:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "A captain of the militia.", GENDER.MALE )
end

function Captain:OnAgentEvent( event_name, agent, ... )
	if event_name == AGENT_EVENT.STRATEGIZE then
		local target = ...
		for i, job in ipairs( self.patrols ) do
			job:SetLocation( target )
		end
	end
end

function Captain:Recruit( job )
	if not job.owner or not job.owner:IsSpawned() then
		local recruit = self.world:RequireAgent(
			function()
				local fighter = Agent.Fighter()
				if self:HasAspect( Aspect.Faction ) then
					self:GetAspect( Aspect.Faction ):AssignFaction( fighter )
				end
				return self.world:SpawnAgent( fighter, self.location )
			end )
			-- function( agent )
			-- 	return not agent:IsPlayer() and
			-- 			not agent:IsEnemy( self ) and
			-- 			agent:CanLearnSkill( Skill.Fighter ) and
			-- 			not agent:IsEmployed()
			-- end )

		recruit:GainAspect( job )
	end
end

function Captain:RecruitAll()
	for i, job in ipairs( self.patrols ) do
		self:Recruit( job )
	end
end
