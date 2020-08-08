local Edible = class( "Aspect.Edible", Aspect )

function Edible:CollectVerbs( verbs, actor, obj )
	if obj == self.owner and actor:CanReach( obj ) then
		verbs:AddVerb( Verb.Eat( nil, self.owner ))
	end
end

function Edible:SetEnergyGain( energy )
	self.energy = energy
	return self
end

function Edible:GetEnergyGain()
	return self.energy or 0
end
