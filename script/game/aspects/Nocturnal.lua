local Nocturnal = class( "Verb.Nocturnal", Verb )

function Nocturnal:OnSpawn( world )
	Verb.OnSpawn( self, world )
	self.actor = self.owner
end

function Nocturnal:CalculateUtility()
	return UTILITY.HABIT
end

function Nocturnal:CanInteract()
	if not Calendar.IsDay( self.actor.world:GetDateTime() ) then
		return false, "Not day"
	end
	if self.actor:InCombat() then
		return false, "In combat"
	end

	return Verb.CanInteract( self )
end

function Nocturnal:Interact()
	while not self:IsCancelled() do
		if not self:DoChildVerb( Verb.Sleep( self.actor )) then
			Msg:Speak( self.actor, "Let me sleep!" )
			self:YieldForTime( ONE_MINUTE )
		end
	end
end
