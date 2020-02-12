--------------------------------------------------------------
--

local Barkeep = class( "Job.Barkeep", Job )

Barkeep.salary = 30

function Barkeep:OnInit()
	self:SetShiftHours( 8, 18 )
end

function Barkeep:GetName()
	return loc.format( "Barkeep at the {1}", self.tavern:GetTitle() )
end

function Barkeep:GetLocation()
	return self.tavern
end

function Barkeep:AssignTavern( tavern )
	assert( tavern == nil or is_instance( tavern, Location ))
	if tavern ~= self.tavern then
		self.tavern = tavern
		if tavern then
			tavern:GetAspect( Feature.Tavern ):AssignBarkeep( self.owner )
		end
	end
end

