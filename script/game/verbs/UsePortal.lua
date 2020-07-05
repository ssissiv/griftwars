local UsePortal = class( "Verb.UsePortal", Verb )

function UsePortal:init( portal )
	Verb.init( self, nil, portal )
end

function UsePortal:CanInteract( actor, portal )
	local ok, reason = (portal or self.obj):CanUsePortal( actor )
	if not ok then
		return false, reason
	end

	return true
end

function UsePortal:Interact( actor, portal )
	portal:ActivatePortal( self )
end

