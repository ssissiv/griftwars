-- Conquest means sending 1 or more fighty-type Agents to a specific location.

local Conquest = class( "Job.Conquest", Job )

function Conquest:OnInit()
	self:SetShiftHours( 0, 24 )
end

function Conquest:SetTarget( target )
	self.target = target
end

function Conquest:RenderAgentDetails( ui, screen, viewer )
	ui.TextColored( 1, 0, 0, 1, "WAR" )
end

function Conquest:SetWaypoint( wp )
	self.waypoint = wp
end

function Conquest:FindCaptain()
	-- Search our faction for subordinates.
	local t = {}
	local faction = self.owner:GetAspect( Aspect.FactionMember )
	if faction then
		for i, subordinate in ipairs( faction:GetSubordinates() ) do
			if not subordinate:HasAspect( Job.Conquest ) then
				table.insert( t, subordinate )
			end
		end
	end

	return self.owner.rng:ArrayPick( t )
end

function Conquest:DoJob()
	if self.captain then
		return false
	end

	if not self.target then
		return false
	end

	local captain = self:FindCaptain()
	if not captain then
		self:SetWaypoint( Waypoint( self.target ))
	else
		self.captain = captain

		local job = Job.Conquest( self.owner )
		captain:GainAspect( job )
		job:SetTarget( self.target )
	end

	-- Monitor jobs.
	return true
end

function Conquest:GetName()
	return loc.format( "Conquest of {1}", self.obj )
end

