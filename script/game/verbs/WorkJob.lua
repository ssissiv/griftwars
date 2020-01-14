local WorkJob = class( "Verb.WorkJob", Verb )

function WorkJob:init( actor, job )

	Verb.init( self, actor )
	self.job = job
	self.travel = self:AddChildVerb( Verb.Travel( actor, self.job ))
end

function WorkJob:GetDesc()
	return loc.format( "Work job as {1}", self.job:GetName() )
end

function WorkJob:GetShortDesc( viewer )
	if viewer == self.giver then
		return "You are working."
	else
		return loc.format( "{1.Id} is here working.", self.actor:LocTable( viewer ))
	end
end

function WorkJob:UpdatePriority( actor, priority )
	local world = actor.world
	if self.job:IsTimeForShift( world:GetDateTime() ) or self:IsDoing() then
		return PRIORITY.OBLIGATION
	else
		return 0
	end
end

function WorkJob:CalculateTimeSpeed()
	local duration = self.job:GetShiftDuration()
	return 64 * (duration / ONE_DAY)
end

function WorkJob:CanInteract( actor )
	if not self.job:IsTimeForShift( self:GetWorld():GetDateTime() ) then
		return false, "Not time for shift"
	end
	return true
end

function WorkJob:Interact( actor )
	-- Track job location and stay around there.
	while self.job:IsTimeForShift( self:GetWorld():GetDateTime() ) do
		self.travel:DoVerb( actor, self.job:GetLocation() )

		if actor:GetLocation() == self.job:GetLocation() then
			Msg:Speak( actor, "Here for work." )

			self:YieldForTime( self.job:GetShiftDuration() )

			if not self:IsCancelled() then
				actor:GainXP( 5 )
				self.job:PaySalary()
			end

		else
			self:YieldForTime( HALF_HOUR )			
		end
	end

	Msg:Speak( actor, "Clocking out." )
end