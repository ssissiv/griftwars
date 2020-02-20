require "game/aspects/Job"

local Assistant = class( "Job.Assistant", Job )

Assistant.salary = 5

function Assistant:OnInit()
	self:SetShiftHours( 8, 16 )
end

function Assistant:GetLocation()
	return self.employer:GetLocation()
end

function Assistant:GetName()
	return loc.format( "Assistant for {1.Id}", self.employer:LocTable())
end
