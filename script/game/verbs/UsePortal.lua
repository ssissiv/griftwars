local UsePortal = class( "Verb.UsePortal", Verb )

function UsePortal:init( actor, portal )
	Verb.init( self, actor )
	assert( portal )
	self.portal = portal
end

function UsePortal:CanInteract()
	local ok, reason = self.portal:CanUsePortal( self.actor )
	if not ok then
		return false, reason
	end

	return true
end

function UsePortal:Interact()
	self.portal:ActivatePortal( self )
end

