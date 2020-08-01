-- Conquest means sending 1 or more fighty-type Agents to a specific location.

local Conquest = class( "Job.Conquest", Job )
Conquest.entity_tags = {"conquest"}

function Conquest:OnInit()
	self:SetShiftHours( 0, 24 )
end

function Conquest:RenderAgentDetails( ui, screen, viewer )
	ui.TextColored( 1, 0, 0, 1, "WAR" )
end

function Conquest:SetWaypoint( wp )
	self.waypoint = wp
end

function Conquest:GetWaypoint()
	return self.waypoint
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

function Conquest:Interact()
	local delegate = self:FindCaptain()
	if delegate then
		self.delegate = delegate

		local job = Job.Conquest( self.owner )
		job:SetWaypoint( self.waypoint )
		delegate:GainAspect( job )

		while not self:IsCancelled() do
			-- Monitor.
			if not delegate:IsSpawned() then
				return
			end
		end

		delegate:LoseAspect( job )

	else
		return Job.Interact( self )
	end
end

function Conquest:GetName()
	return loc.format( "Conquest of {1}", self.obj )
end

