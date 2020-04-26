
local Patrol = class( "Job.Patrol", Job )

Patrol.salary = 5

function Patrol:OnInit()
	self:SetShiftHours( 0, 24 )
end

function Patrol:GetWaypoint()
	return self.waypoint
end

function Patrol:SetWaypoint( waypoint )
	self.waypoint = waypoint
end

function Patrol:RenderAgentDetails( ui, screen, viewer )
	local location = self.waypoint and self.waypoint:GetLocation()
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
	self:YieldForTime( ONE_HOUR )
end

function Patrol:GetName()
	local faction = self.employer:GetAspect( Aspect.Faction )
	if faction then
		return loc.format( "{1} Patrol", faction:GetName() )
	else
		return loc.format( "Patrol for {1.Id}", self.employer:LocTable())
	end
end

