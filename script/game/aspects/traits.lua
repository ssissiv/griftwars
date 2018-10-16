local Trait = class( "Trait", Aspect )

---------------------------------------------------------------

local Cowardly = class( "Trait.Cowardly", Aspect )

function Cowardly:CollectInteractions( actor, obj, verbs )
	if actor ~= self.agent and obj == self.agent then
		if verbs then
			table.insert( verbs, Verb.Intimidate( actor, obj ) )
		end
		return true
	end
end

---------------------------------------------------------------

local Poor = class( "Trait.Poor", Aspect )

function Poor:CollectInteractions( actor, obj, verbs )
	if actor ~= self.agent and obj == self.agent then
		if verbs then
			table.insert( verbs, Verb.OfferMoney( actor, obj ) )
		end
		return true
	end
end
