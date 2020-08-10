local CloseObject = class( "Verb.CloseObject", Verb )

CloseObject.act_desc = "Close"

function CloseObject:init( actor, obj )
	Verb.init( self, actor )
	assert( is_instance( obj, Object ))
	self.obj = obj
end

function CloseObject:CanInteract()
	if not self.actor:CanReach( self.obj ) then
		return false, "Not adjacent"
	end
	return true
end

function CloseObject:Interact()
	Msg:EchoTo( self.actor, "You close the {1.Id}.", self.obj:LocTable( self.actor ))
	self.obj:Close()
end

