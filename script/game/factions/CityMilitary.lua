local CityMilitary = class( "Faction.CityMilitary", Faction )

function CityMilitary:init( name, guard_count )
	Faction.init( self, name )
	self.patrol_locations = {}
	self.jobs = {}
	self.guard_count = guard_count
end

function CityMilitary:OnSpawn( world )
	Faction.OnSpawn( self, world )

	do
		self.commander = world:SpawnEntity( Agent.Commander() )
		self:AddFactionMember( self.commander, FACTION_ROLE.COMMANDER )

		local job = Job.Conquest( self.commander )
		self.commander:GainAspect( job )
	end

	for i = 1, math.max( 1, math.floor( self.guard_count / 10 )) do
		local captain = world:SpawnEntity( Agent.Captain() )
		self:AddFactionMember( captain, FACTION_ROLE.CAPTAIN )

		local job = Job.Patrol( self.commander )
		captain:GainAspect( job )
		-- table.insert( self.jobs, job )
	end

	for i = 1, self.guard_count do
		local guard = world:SpawnEntity( Agent.CityGuard() )
		self:AddFactionMember( guard, FACTION_ROLE.GUARD )
	end
end

function CityMilitary:AddPatrolLocation( location )
	table.insert( self.patrol_locations, location )

	local employer = self.world:ArrayPick( self:GetAgentsByRole( FACTION_ROLE.CAPTAIN ))
	if employer == nil then
		DBG( self )
		return
	end

	local captain_job = employer:GetAspect( Job.Patrol )
	if captain_job then
		-- Captain patrols this place too.
		captain_job:AddWaypoint( Waypoint( location ))
	end

	local job = Job.Patrol( employer )
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
