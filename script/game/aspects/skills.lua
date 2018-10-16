local Skill = class( "Skill", Aspect )

function Skill:CollectInteractions( actor, obj, verbs )
	if self.verb and self.agent == actor and obj == nil then
		if verbs then
			table.insert( verbs, self.verb() )
		end
		return true
	end
end

---------------------------------------------------------------

local Scrounge = class( "Skill.Scrounge", Skill )
Scrounge.verb = Verb.Scrounge

---------------------------------------------------------------
