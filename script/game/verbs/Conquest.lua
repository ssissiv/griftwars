
local Conquest = class( "Job.Conquest", Job )

function Conquest:OnInit()
	self:SetShiftHours( 0, 24 )
end

function Conquest:RenderAgentDetails( ui, screen, viewer )
	ui.TextColored( 1, 0, 0, 1, "WAR" )
end

function Conquest:GetWaypoint()
	-- where I be conquesting.
	return Waypoint( self.actor )
end

function Conquest:FindCaptain()
	-- Search our faction for subordinates.
	local t = {}
	local faction = self.owner:GetAspect( Aspect.FactionMember )
	if faction then
		for i, subordinate in ipairs( faction:GetSubordinates() ) do
			if not subordinate:HasAspect( Aspect.Job ) then
				table.insert( t, subordinate )
			end
		end
	end

	return self.owner.rng:ArrayPick( t )
end

function Conquest:DoJob()
	local captain = self:FindCaptain()
	print( "FOUND:", captain )
	-- How many squads are we commanding here?
	for i, captain in ipairs( captains ) do
		-- Give them their own Conquest jobs.
		local job = Job.Conquest()
		job:SetTarget( self.target )
	end

	-- Monitor jobs.
end

function Conquest:GetName()
	return loc.format( "Conquest of {1}", self.obj )
end

