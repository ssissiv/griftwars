local WorkJob = class( "Verb.WorkJob", Verb )

function WorkJob:init( actor, job )

	Verb.init( self, actor )
	self.job = job
	self.travel = self:AddChildVerb( Verb.Travel( actor, self.job ))
end

function WorkJob:GetDesc()
	return loc.format( "Work job as {1}", self.job:GetName() )
end

function WorkJob:UpdatePriority( actor, priority )
	local world = actor.world
	if self.job:IsTimeForShift( world:GetDateTime() ) or self:IsDoing() then
		return PRIORITY.OBLIGATION
	else
		return 0
	end
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
			end

		else
			self:YieldForTime( HALF_HOUR )			
		end
	end

	Msg:Speak( actor, "Clocking out." )
end