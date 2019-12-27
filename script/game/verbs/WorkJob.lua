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
	return PRIORITY.OBLIGATION
end

function WorkJob:Interact( actor )
	self.travel:DoVerb( actor, self.job:GetLocation() )

	if actor:GetLocation() == self.job:GetLocation() then
		Msg:Speak( actor, "Here for work." )
	end

	self:YieldForTime( ONE_HOUR )

	Msg:Speak( actor, "Clocking out." )
end