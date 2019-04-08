local Verb = class( "Verb" )

function Verb:init( actor, obj )
	self.actor = actor
	self.obj = obj
	print( "MAKE", self, debug.traceback() )
end

function Verb:AssignActor( actor )
	self.actor = actor
end

function Verb:AssignObj( obj )
	self.obj = obj
end

function Verb:GetDC()
	if self.dc == nil and self.CalculateDC then
		self.dc = self:CalculateDC( Modifiers() )
	end
	return self.dc or 0
end

function Verb:CheckDC()
	return math.random( 1, 20 ) >= self:GetDC()
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
