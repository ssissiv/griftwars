
local Socialize = class( "Verb.Socialize", Verb )
Socialize.MSG =
{
	"Hey there. How's it going?",
}

function Socialize.CollectInteractions( actor, verbs )
	if actor.location then
		for i, obj in actor.location:Contents() do
			if actor:GetFocus() == obj and obj:GetFocus() == actor and is_instance( actor, Agent ) then
				table.insert( verbs, Verb.Socialize( actor, obj ))
			end
		end
	end
end


function Socialize:GetDesc()
	return "Socialize"
end

function Socialize:CalculateDC( mods )
	mods:AddModifier( self.obj:GetPrestige(), loc.format( "{1.Id}'s prestige" ))

	mods:AddModifier( -self.actor:GetPrestige(), loc.format( "{1.Id}'s prestige" ))

	return 10 + mods:GetValue()
end

function Socialize:Interact( actor, obj )
	if self:CheckDC() then
		Msg:Speak( self.MSG, actor, obj )
		if not actor:CheckPrivacy( obj, PRIVACY.ID ) then
			actor:GetMemory():AddEngram( Engram.MakeKnown( obj, PRIVACY.ID ))
			obj:RegenerateLocTable( actor )
			Msg:Echo( actor, "You learn {1.id}'s name.", obj:LocTable( actor ))
		else
			obj:DeltaOpinion( actor, OPINION.LIKE, 1 )
		end
	else
		Msg:Speak( self.MSG, actor, obj )
		Msg:Echo( actor, "{1.Id} doesn't seem to care much for your attempt at interaction.", obj:LocTable( actor ))
	end
end
