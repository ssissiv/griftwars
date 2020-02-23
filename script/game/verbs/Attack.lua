local Attack = class( "Verb.Attack", Verb )

Attack.ACT_RATE = 3/60

function Attack:init( actor )
	Verb.init( self, actor )
	self.combat = actor:GetAspect( Aspect.Combat )
end

function Attack:GetShortDesc( viewer )
	if viewer == self:GetOwner() then
		return "You are attacking!"
	else
		return loc.format( "{1.Id} is here attacking!", self.actor:LocTable( viewer ))
	end
end

function Attack:CollectVerbs( verbs, actor, obj )
	if not self or actor ~= self.owner then
		return false
	end
	if obj then
		return false
	end
	local combat = actor:GetAspect( Aspect.Combat )
	if not combat or not combat:HasTargets() then
		return false
	end

	verbs:AddVerb( self )
end

function Attack:CalculateUtility( actor )
	return UTILITY.COMBAT
end

function Attack:CanInteract( actor )
	return actor:IsSpawned() and self.combat:HasTargets()
end

function Attack:Interact( actor )
	self:YieldForTime( ONE_MINUTE )

	if self:IsCancelled() then
		return
	end

	assert( actor:IsSpawned(), actor )
	assert( actor.location, actor )
	local target = self.combat:PickTarget()
	Msg:ActToRoom( "{1.Id} attacks {2.Id}!", actor, target )
	Msg:Echo( actor, loc.format( "You attack {1.Id}!", target:LocTable( self.owner ) ))
	Msg:Echo( target, loc.format( "{1.Id} attacks you!", actor:LocTable( target ) ))

	target:DeltaHealth( -1 )
end
