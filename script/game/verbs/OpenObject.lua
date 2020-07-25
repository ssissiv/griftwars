local OpenObject = class( "Verb.OpenObject", Verb )

OpenObject.act_desc = "Open"

function OpenObject:init( target )
	assert( target )
	Verb.init( self, nil, target )
end

function OpenObject:CanInteract( actor, target )
	if not actor:CanReach( target ) then
		return false, "Not adjacent"
	end
	local lock = target:GetAspect( Aspect.Lock )
	if lock and lock:IsLocked() then
		return false, "Locked"
	end
	return true
end

function OpenObject:Interact( actor, target )
	Msg:EchoTo( actor, "You open the {1.Id}.", target:LocTable( actor ))
	target:Open()
end

