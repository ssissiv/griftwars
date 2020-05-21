local CityMilitary = class( "Faction.CityMilitary", Faction )

function CityMilitary:init( name, guard_count )
	Faction.init( self, name )
	self.guard_count = guard_count
end

function CityMilitary:OnSpawn( world )
	self.roles = {}

	local commander = world:SpawnEntity( Agent.Captain() )
	self:AddFactionMember( commander, FACTION_ROLE.CAPTAIN )

	for i = 1, self.guard_count do
		local guard = world:SpawnEntity( Agent.CityGuard() )
		self:AddFactionMember( guard, FACTION_ROLE.GUARD )
	end
end
