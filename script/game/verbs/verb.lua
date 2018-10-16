local Verb = class( "Verb" )

function Verb:init( actor, obj )
	self.actor = actor
	self.obj = obj
end

function Verb:CanInteract( actor, obj )
	return true
end

function Verb:__tostring()
	if self.obj then
		return string.format( "<%s : %s>", self._classname, tostring(self.obj))
	else
		return string.format( "<%s>", self._classname )
	end
end
