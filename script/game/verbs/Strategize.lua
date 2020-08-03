
local Strategize = class( "Verb.Strategize", Verb.Plan )

function Strategize:GetDesc( viewer )
	if self.target then
		return loc.format( "Strategizing to capture {1}", self.target )
	end
end

function Strategize:CalculateUtility( actor )
	return UTILITY.DUTY - 1
end

function Strategize:FindStrategicPoint( actor )
	local assault_pts, defend_pts = {}, {}
	local function IsStrategicPoint( location, depth )
		if location:HasAspect( Feature.StrategicPoint ) then
			if actor:IsEnemy( location ) then
				table.insert( assault_pts, location )
			elseif actor:IsAlly( location ) then
				table.insert( defend_pts, location )
			end
		end

		-- self:YieldForTime( ONE_MINUTE )

		return depth < 12
	end

	actor.location:Flood( IsStrategicPoint )

	if #assault_pts > 0 then
		return self:GetWorld():ArrayPick( assault_pts )
	else
		return self:GetWorld():ArrayPick( defend_pts )
	end
end

-- function Strategize:CanInteract( actor )
-- 	return false, "Disabled"
-- end

function Strategize:Interact( actor )
	while not self:IsCancelled() do
		self:YieldForTime( HALF_HOUR )

		self.target = self:FindStrategicPoint( actor )

		if self.target then
			Msg:Speak( actor, "Hmm... where should this brigade go..." )
	
			if actor:IsEnemy( self.target ) then
				Msg:Speak( actor, "We must assault {1}!", self.target )
				Msg:Speak( actor, "{1} must be stopped.", self.target:GetAspect( Aspect.FactionMember ):GetName() )
			elseif self.target == actor.location then
				Msg:Speak( actor, "We will occupy this location." )
			else
				Msg:Speak( actor, "We will occupy {1}.", self.target )
			end

			if not actor:HasAspect( Job.Conquest ) then
				local job = Job.Conquest( actor )
				job:SetWaypoint( Waypoint( self.target ))
				actor:GainAspect( job )
			end
		end

		self:YieldForTime( ONE_DAY * 3 )
	end
end
