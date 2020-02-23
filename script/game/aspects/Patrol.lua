
local Patrol = class( "Job.Patrol", Job )

Patrol.salary = 5

function Patrol:OnInit()
	self:SetShiftHours( 6, 15 )
end

function Patrol:GetLocation()
	return self.location
end

function Patrol:SetLocation( location )
	self.location = location
end

function Patrol:GetName()
	local faction = self.employer:GetAspect( Aspect.Faction )
	if faction then
		return loc.format( "{1} Patrol", faction:GetName() )
	else
		return loc.format( "Patrol for {1.Id}", self.employer:LocTable())
	end
end

