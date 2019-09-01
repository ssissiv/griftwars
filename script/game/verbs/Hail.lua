
local Hail = class( "Verb.Hail", Verb )
Hail.STRINGS =
{
	"You hail {2.id}'s attention.",
	"{1.Id} hails you.",
	"{1.Id} hails {2.id}.",
}

function Hail.CollectInteractions( actor, verbs )
	if actor.location then
		for i, obj in actor.location:Contents() do
			if actor:GetFocus() == obj and obj:GetFocus() ~= actor and is_instance( obj, Agent ) then
				table.insert( verbs, Verb.Hail( actor, obj ))
			end
		end
	end
end


function Hail:GetDesc( obj )
	return "Hail"
end

function Hail:CanInteract()
	if self.obj:IsBusy() then
		return false, loc.format( "{1.Id} is busy.", self.obj:LocTable( self.actor ) )
	end

	return true
end

function Hail:Interact( actor, obj )
	Msg:Action( self.STRINGS, actor, obj )
	obj:SetFocus( self.actor )
	Msg:Speak( "What do you want?", obj, actor )
end
