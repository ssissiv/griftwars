
local Socialize = class( "Verb.Socialize", Verb )
Socialize.MSG =
{
	"Hey {2.name}. How's it going?",
}

function Socialize.CollectInteractions( actor, verbs )
	if actor.location then
		for i, obj in actor.location:Contents() do
			if actor:GetFocus() == obj and is_instance( actor, Agent ) then
				table.insert( verbs, Verb.Socialize( actor, obj ))
			end
		end
	end
end


function Socialize:GetDesc()
	return "Socialize"
end

function Socialize:CalculateDC( mods )
	mods:AddModifier( self.obj:GetPrestige(), loc.format( "{1.name}'s prestige" ))

	mods:AddModifier( -self.actor:GetPrestige(), loc.format( "{1.name}'s prestige" ))

	return 10 + mods:GetValue()
end

function Socialize:Interact( actor, obj )
	if self:CheckDC() then
		Msg:Speak( self.MSG, actor, obj )
		obj:DeltaOpinion( actor, OPINION.LIKE, 1 )
	else
		Msg:Speak( self.MSG, actor, obj )
		Msg:Echo( actor, "{1.name} doesn't seem to care much for your attempt at interaction.", obj )
	end
end
