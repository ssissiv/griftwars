local Skill = class( "Skill", Aspect )

function Skill:CollectInteractions( actor, obj, verbs )
	assert( self.verb or self.location_verb, self._classname )
	local verb

	if self.verb then
		if self.agent == actor and is_instance( obj, Agent ) then
			verb = self.verb
		end
	elseif self.location_verb then
		if self.agent == actor and obj == nil then
			verb = self.location_verb
		end
	else
		error()
	end

	if verb then
		if verbs then
			verb = verb( actor, obj )
			table.insert( verbs, verb )
		end
		return true
	end
end

---------------------------------------------------------------

local Scrounge = class( "Skill.Scrounge", Skill )
Scrounge.location_verb = Verb.Scrounge

---------------------------------------------------------------

local Socialize = class( "Skill.Socialize", Skill )
Socialize.verb = Verb.Socialize
