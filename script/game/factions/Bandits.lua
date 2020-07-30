local Bandits = class( "Faction.Bandits", Faction )

function Bandits:init()
	Faction.init( self, "Bandits" )
end

function Bandits:OnSpawn( world )
	Faction.OnSpawn( self, world )

	do
		self.captain = world:SpawnEntity( Agent.Bandit() )
		self:AddFactionMember( self.captain, FACTION_ROLE.CAPTAIN )

		-- local job = Job.Conquest( self.commander )
		-- self.commander:GainAspect( job )
	end

	for i = 1, 3 do
		local guard = world:SpawnEntity( Agent.Bandit() )
		self:AddFactionMember( guard, FACTION_ROLE.GUARD )
	end
end

function Bandits:SpawnTents( room )
	local bandits = self:GetAgentsByRole( FACTION_ROLE.GUARD )
	local tent_count = math.ceil( #bandits / 3 )
	for i = 1, #bandits, 3 do
		local tent = Object.Tent()
		tent:WarpToLocation( room )
		local interior = tent:SpawnInterior()
		interior:GainAspect( Aspect.FactionMember( self ))
		local home = interior:GetAspect( Feature.Home )

		for j = i, i + 2 do
			bandits[j]:WarpToLocation( interior )
			home:AddResident( bandits[j] )
		end
	end
end
