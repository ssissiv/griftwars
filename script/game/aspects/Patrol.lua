
local Patrol = class( "Job.Patrol", Job )

Patrol.salary = 5

function Patrol:OnInit()
	self:SetShiftHours( 0, 24 )
end

function Patrol:GetLocation()
	return self.location
end

function Patrol:SetLocation( location )
	self.location = location
end

function Patrol:RenderAgentDetails( ui, screen, viewer )
	if self.location then
		ui.Bullet()
		if self.owner:IsAlly( self.location ) then
			ui.Text( loc.format( "Defending {1}", self.location ))
		elseif self.owner:IsEnemy( self.location ) then
			ui.Text( loc.format( "Assaulting {1}", self.location ))
		else
			ui.Text( loc.format( "Occupying {1}", self.location ))
		end
	end
end

function Patrol:GetName()
	local faction = self.employer:GetAspect( Aspect.Faction )
	if faction then
		return loc.format( "{1} Patrol", faction:GetName() )
	else
		return loc.format( "Patrol for {1.Id}", self.employer:LocTable())
	end
end

