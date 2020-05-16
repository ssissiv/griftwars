local Killed = class( "Aspect.Killed", Aspect )

function Killed:CollectVerbs( verbs, actor, obj )
	if obj == self.owner then
		local inv  = self.owner:GetAspect( Aspect.Inventory )
		if inv and not inv:IsEmpty() then
			verbs:AddVerb( Verb.LootInventory( inv ))
		end
	end
end
