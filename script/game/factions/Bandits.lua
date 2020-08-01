local Bandits = class( "Faction.Bandits", Faction )

function Bandits:init()
	Faction.init( self, "Bandits" )
end

function Bandits:OnSpawn( world )
	Faction.OnSpawn( self, world )

	do
		self.captain = world:SpawnEntity( Agent.Bandit() )
		self:AddFactionMember( self.captain, FACTION_ROLE.CAPTAIN, "captain of the bandits" )

		self.captain:GainAspect( Verb.Strategize() )
	end

	for i = 1, 3 do
		local guard = world:SpawnEntity( Agent.Bandit() )
		self:AddFactionMember( guard, FACTION_ROLE.GUARD )
	end

	-- Enemy of all lawful factions
	for i, faction in pairs( world:GetBucketByClass( Faction )) do
		if faction:IsLawful() then
			faction:AddTagForFaction( self, FACTION_TAG.ENEMY )
			self:AddTagForFaction( faction, FACTION_TAG.ENEMY )
		end
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

		-- Warp and set this tent as the home of these bandits.
		for j = i, i + 2 do
			bandits[j]:WarpToLocation( interior )
			home:AddResident( bandits[j] )
		end

		-- Captain is the first tent.
		if i == 1 then
			self.captain:WarpToLocation( interior )
			home:AddResident( self.captain )
		end
	end
end