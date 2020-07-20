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

	local function RaycastProjectile( start_room, end_room, plot )
		local x0, y0 = start_room:GetCoordinate()
		local x1, y1 = end_room:GetCoordinate()
	    local dx = math.abs( x1 - x0 )
	   	local sx = x0 < x1 and 1 or -1
		local dy = -math.abs( y1 - y0 )
	    local sy = y0 < y1 and 1 or -1
	    local err = dx + dy
	    local path = {}
	    while true do
			local tile = actor.location:LookupTile( x0, y0 )
			if not tile then --or not tile:IsConditionallyPassable( self.actor ) then
				return
			else
				table.insert( path, tile )
			end

			self.proj:WarpToTile( tile )
			-- self:YieldForInterrupt( target, "incoming!" )
			self:YieldForTime( 0.5 * ONE_SECOND )

			if x0 == x1 and y0 == y1 then
				break
			end

	        local e2 = 2*err
	        if e2 >= dy then
	            err = err + dy
	            x0 = x0 + sx
			end
	        if e2 <= dx then
	        	err = err + dx
	        	y0 = y0 + sy
	        end
	    end

	    return path
	end

	local target_tile = target:GetTile()
	RaycastProjectile( actor:GetTile(), target:GetTile() )

	if target:GetTile() == target_tile then
		Verb.RangeAttack.Interact( self, actor, target )
	end
end
