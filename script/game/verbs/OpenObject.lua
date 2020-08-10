local OpenObject = class( "Verb.OpenObject", Verb )

OpenObject.act_desc = "Open"

function OpenObject:init( actor, target )
	Verb.init( self, actor )
	assert( target )
	self.target = target
end

function OpenObject:CanInteract()
	if not self.actor:CanReach( self.target ) then
		return false, "Not adjacent"
	end
	local lock = self.target:GetAspect( Aspect.Lock )
	if lock and lock:IsLocked() then
		return false, "Locked"
	end
	return true
end

function OpenObject:Interact()
	Msg:EchoTo( self.actor, "You open the {1.Id}.", self.target:LocTable( self.actor ))
	self.target:Open()
end

