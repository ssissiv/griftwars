local ThrowObject = class( "Verb.ThrowObject", Verb.RangeAttack )

ThrowObject.INTENT_FLAGS = INTENT.HOSTILE
ThrowObject.act_desc = "Throw"

function ThrowObject:CanInteract( actor, target )
	return Verb.RangeAttack.CanInteract( self, actor, target )
end

function ThrowObject:SetProjectile( proj )
	self.fatigue_cost = proj and proj.mass
	return Verb.RangeAttack.SetProjectile( self, proj )
end

function ThrowObject:GetDesc( viewer )
	return loc.format( "Throwing {1.desc}", self.proj )
end

function ThrowObject:GetActDesc( actor )
	return loc.format( "Throw {1.desc} for {2} damage", self.proj, self:CalculateDamage( self.obj ))
end	

function ThrowObject:CalculateUtility( actor )
	return 20
end

function ThrowObject:CollectVerbs( verbs, actor, target )
	if verbs.id == "attacks" and actor:GetHeldObject() then
		verbs:AddVerb( Verb.ThrowObject():SetProjectile( actor:GetHeldObject() ):SetTarget( target ) )
	end
end

function ThrowObject:CalculateDC()
	return 2
end

function ThrowObject:Interact( actor, target )
	assert( self.proj == actor:GetHeldObject() )
	
	self.proj:GetAspect( Aspect.Wearable ):Unequip()
	actor:GetInventory():RemoveItem( self.proj )
	self.proj:WarpToLocation( actor:GetLocation(), actor:GetCoordinate() )
	self.proj:LoseAspect( Aspect.Carryable )

	local target_tile = target:GetTile()
	Raycast.Projectile( actor:GetLocation(), actor:GetTile(), target:GetTile(), self.proj )

	self.proj:GainAspect( Aspect.Carryable() )

	if target:GetTile() == self.proj:GetTile() then
		Verb.RangeAttack.Interact( self, actor, target )
	end
end
