local Skill = class( "Skill", Aspect )

function Skill:CollectInteractions( actor, obj, verbs )
	assert( self.verb_class or self.location_verb_class, self._classname )
	local verb_class

	if self.verb_class then
		if self.agent == actor and is_instance( obj, Agent ) then
			verb_class = self.verb_class
		end
	elseif self.location_verb_class then
		if self.agent == actor and obj == nil then
			verb_class = self.location_verb_class
		end
	else
		error()
	end

	if verb_class then
		if verbs then
			local verb = self:CreateVerb( verb_class, actor, obj )
			table.insert( verbs, verb )
		end
		return true
	end
end

---------------------------------------------------------------

local Scrounge = class( "Skill.Scrounge", Skill )
Scrounge.location_verb_class = Verb.Scrounge

---------------------------------------------------------------

local Socialize = class( "Skill.Socialize", Skill )
Socialize.verb_class = Verb.Socialize

---------------------------------------------------------------

local RumourMonger = class( "Skill.RumourMonger", Skill )
RumourMonger.verb_class = Verb.ExchangeRumours


