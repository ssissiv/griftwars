
local HamstringSkill = class( "Skill.Hamstring", Aspect.Skill )

HamstringSkill.desc = "A melee attack that Hobbles your target."
HamstringSkill.name = "Hamstring"

function HamstringSkill:init()
	Aspect.Skill.init( self, self._classname, 1, 3 )
	self:SetGrowthRate( 0.1 )
end

function HamstringSkill:CollectVerbs( verbs, actor, target )
	if actor == self.owner and target and target ~= actor and target:HasAspect( Aspect.Combat ) then
		verbs:AddVerb( Verb.Hamstring( actor, target ))
	end
end