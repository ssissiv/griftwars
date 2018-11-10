
local Socialize = class( "Verb.Socialize", Verb )
Socialize.STRINGS =
{
	"Hey {2.name}. How's it going?",
}

function Socialize:GetDesc()
	return "Socialize"
end

function Socialize:CalculateDC( mods )
	mods:AddModifier( self.obj:GetPrestige(), loc.format( "{1.name}'s prestige" ))

	mods:AddModifier( -self.actor:GetPrestige(), loc.format( "{1.name}'s prestige" ))

	return mods:GetValue()
end

function Socialize:Interact( actor, obj )
	Msg:Speak( self.STRINGS, actor, obj )
	obj:GetSocialNode():ImproveRelationship( actor )
end
