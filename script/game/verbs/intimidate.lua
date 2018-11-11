
local Intimidate = class( "Verb.Intimidate", Verb )
Intimidate.SUCCESS_MSG =
{
	"You push {2.name} around and enjoy it.",
	"{1.name} pushes you around roughly. Jerk.",
	"{1.name} pushes {2.name} around.",
}
Intimidate.FAIL_MSG =
{
	"You try to intimidate {2.name} around but {2.heshe} knocks you senseless.",
	"{1.name} tries to intimidate you around but you knock them flat.",
	"{1.name} tries to intimidate {2.name} around but ends up being knocked around.",
}


function Intimidate:GetDesc()
	return "Intimidate"
end

function Intimidate:CalculateDC( mods )
	mods:AddModifier( self.obj:GetPrestige(), loc.format( "{1.name}'s prestige" ))

	mods:AddModifier( -self.actor:GetPrestige(), loc.format( "{1.name}'s prestige" ))

	return 10 + mods:GetValue()
end

function Intimidate:Interact( actor, obj )
	if self:CheckDC() then
		Msg:Action( self.SUCCESS_MSG, actor, obj )
		obj:DeltaOpinion( actor, OPINION.FEAR, 1 )
	else
		Msg:Action( self.FAIL_MSG, actor, obj )
		actor:DeltaOpinion( obj, OPINION.FEAR, 1 )
	end
end
