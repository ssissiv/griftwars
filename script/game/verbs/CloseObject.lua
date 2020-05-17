local CloseObject = class( "Verb.CloseObject", Verb )

function CloseObject:init( target )
	Verb.init( self, nil, target )
end

function CloseObject:CanInteract( actor, target )
	if not actor:IsAdjacent( target ) then
		return false, "Not adjacent"
	end
	return true
end

function CloseObject:Interact( actor, target )
	Msg:Echo( actor, "You close the {1.Id}.", target:LocTable( actor ))
	target:Close()
end

