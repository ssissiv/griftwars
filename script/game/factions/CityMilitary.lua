local CityMilitary = class( "Faction.CityMilitary", Faction )

function CityMilitary:init( name, guard_count )
	Faction.init( self, name )
	self.patrol_locations = {}
	self.jobs = {}
	self.guard_count = guard_count
end

function CityMilitary:OnSpawn( world )

	self.commander = world:SpawnEntity( Agent.Captain() )
	self:AddFactionMember( self.commander, FACTION_ROLE.CAPTAIN )

	for i = 1, self.guard_count do
		local guard = world:SpawnEntity( Agent.CityGuard() )
		self:AddFactionMember( guard, FACTION_ROLE.GUARD )
	end
end

function CityMilitary:AddPatrolLocation( location )
	table.insert( self.patrol_locations, location )

	local job = Job.Patrol( self.commander )
	job:SetWaypoint( Waypoint( location ))
	table.insert( self.jobs, job )

	-- Find a guard to assign this job to.
	for i, guard in ipairs( self:GetAgentsByRole( FACTION_ROLE.GUARD )) do
		if not guard:HasAspect( Job ) then
			guard:GainAspect( job )
			break
		end
	end
end
