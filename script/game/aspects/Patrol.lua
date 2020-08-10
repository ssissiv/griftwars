
local Patrol = class( "Job.Patrol", Job )

Patrol.salary = 5

function Patrol:OnInit()
	self:SetShiftHours( 0, 24 )
	self.waypoints = {}
end

function Patrol:GetWaypoint()
	return self.waypoints[1]
end

function Patrol:SetWaypoint( waypoint )
	table.clear( self.waypoints )
	self:AddWaypoint( waypoint )
end

function Patrol:AddWaypoint( waypoint )
	table.insert( self.waypoints, waypoint )
end

function Patrol:RenderAgentDetails( ui, screen, viewer )
	local waypoint = self:GetWaypoint()
	local location = waypoint and waypoint:GetLocation()
	if location then
		ui.Bullet()
		if self.owner:IsAlly( location ) then
			ui.Text( loc.format( "Defending {1}", location ))
		elseif self.owner:IsEnemy( location ) then
			ui.Text( loc.format( "Assaulting {1}", location ))
		else
			ui.Text( loc.format( "Occupying {1}", location ))
		end
	end
end

function Patrol:DoJob()
	if self.owner:IsEnemy( self.owner:GetLocation() ) then
		Msg:Speak( self.owner, "Stay alert! We're in enemy territory." )
	else
		Msg:Speak( self.owner, "Holding this location." )
	end
	self:DoChildVerb( Verb.Wander( self.owner ):SetDuration( ONE_HOUR ))

	-- Next waypoint.
	table.remove( self.waypoints, 1 )
	table.insert( self.waypoints, self.current_waypoint )

	return true
end

function Patrol:GetName()
	local faction = self.employer:GetAspect( Aspect.FactionMember )
	if faction then
		return loc.format( "{1} Patrol", faction:GetName() )
	else
		return loc.format( "Patrol for {1.Id}", self.employer:LocTable())
	end
end

