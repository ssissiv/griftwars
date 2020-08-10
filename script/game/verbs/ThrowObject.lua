local ThrowObject = class( "Verb.ThrowObject", Verb.RangeAttack )

ThrowObject.INTENT_FLAGS = INTENT.HOSTILE
ThrowObject.act_desc = "Throw"

function ThrowObject:init( actor, target, proj )
	Verb.RangeAttack.init( self, actor, target )
	self.proj = proj
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

function ThrowObject:CalculateDC()
	return 2
end

function ThrowObject:Interact()
	local actor, target = self.actor, self.target
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
