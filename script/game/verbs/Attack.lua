local Attack = class( "Verb.Attack", Verb )

function Attack:init( actor )
	Verb.init( self, actor )
	self.combat = actor:GetAspect( Aspect.Combat )
end

function Attack:CalculateUtility( actor )
	return UTILITY.COMBAT
end

function Attack:CanInteract( actor )
	return self.combat:HasTargets()
end

function Attack:Interact( actor )
	self:YieldForTime( ONE_MINUTE )

	if self:IsCancelled() then
		return
	end

	local target = self.combat:PickTarget()
	Msg:ActToRoom( "{1.Id} attacks {2.Id}!", actor, target )
	Msg:Echo( actor, loc.format( "You attack {1.Id!}", target:LocTable( self.owner ) ))
	Msg:Echo( target, loc.format( "{1.Id} attacks you!", actor:LocTable( target ) ))
end
