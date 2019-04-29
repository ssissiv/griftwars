local Verb = class( "Verb" )

function Verb:init( actor, obj )
	self.actor = actor
	self.obj = obj
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

function Verb:BeginActing()
	self.actor:AssignVerb( self )

	if self.VERB_DURATION then
		local world = self.actor.world
		self.start_time = world:GetDateTime()
		self.start_duration = self.VERB_DURATION
		self.start_ev = world:ScheduleFunction( self.start_duration, self.EndActing, self )
	else
		self:EndActing()
	end
end

function Verb:GetActingProgress()
	if self.start_ev and self.start_duration then
		return 1.0 - (self.start_ev.when - self.actor.world:GetDateTime()) / self.start_duration
	end
end

function Verb:EndActing()
	self.actor:UnassignVerb( self )
	self:Interact( self.actor, self.obj )
end

function Verb:__tostring()
	if self.obj then
		return string.format( "<%s : %s>", self._classname, tostring(self.obj))
	else
		return string.format( "<%s>", self._classname )
	end
end
