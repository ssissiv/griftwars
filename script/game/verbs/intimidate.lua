
local Intimidate = class( "Verb.Intimidate", Verb )
Intimidate.STRINGS =
{
	"You push {2.name} around and enjoy it.",
	"{1.name} pushes you around roughly. Jerk.",
	"{1.name} pushes {2.name} around.",
}

function Intimidate:GetDesc()
	return "Intimidate"
end

function Intimidate:CalculateDC( mods )
	mods:AddModifier( self.obj:GetPrestige(), loc.format( "{1.name}'s prestige" ))

	mods:AddModifier( -self.actor:GetPrestige(), loc.format( "{1.name}'s prestige" ))

	return mods:GetValue()
end

function Intimidate:Interact( actor, obj )
	Msg:Action( self.STRINGS, actor, obj )
	obj:GetSocialNode():DegradeRelationship( actor )
	actor:DeltaStat( STAT.CRUELTY, 1 )
end
