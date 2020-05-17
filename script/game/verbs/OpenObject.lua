local OpenObject = class( "Verb.OpenObject", Verb )

function OpenObject:init( target )
	Verb.init( self, nil, target )
end

function OpenObject:CanInteract( actor, target )
	if not actor:IsAdjacent( target ) then
		return false, "Not adjacent"
	end
	return true
end

function OpenObject:Interact( actor, target )
	Msg:Echo( actor, "You open the {1.Id}.", target:LocTable( actor ))
	target:Open()
end

