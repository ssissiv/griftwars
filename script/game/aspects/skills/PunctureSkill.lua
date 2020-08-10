
local PunctureSkill = class( "Skill.Puncture", Aspect.Skill )

PunctureSkill.desc = "A melee attack with Piercing I."
PunctureSkill.name = "Puncture"

function PunctureSkill:init()
	Aspect.Skill.init( self, self._classname, 1, 3 )
	self:SetGrowthRate( 0.1 )
end

function PunctureSkill:CollectVerbs( verbs, actor, target )
	if actor == self.owner and target and target ~= actor and target:HasAspect( Aspect.Combat ) then
		verbs:AddVerb( Verb.Puncture( actor,target ))
	end
end
