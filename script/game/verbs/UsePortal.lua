local UsePortal = class( "Verb.UsePortal", Verb )

function UsePortal:Interact( actor, portal )
	portal:ActivatePortal( self )
end

