local Verb = class( "Verb" )

function Verb:init( actor, obj )
	self.actor = actor
	self.obj = obj
end

function Verb.RecurseSubclasses( class, fn )
	class = class or Verb
	fn( class )

	for i, subclass in ipairs( class._subclasses ) do
		Verb.RecurseSubclasses( subclass, fn )
	end
end

function Verb:AssignActor( actor )
	assert( self.actor == nil or actor == self.actor )
	self.actor = actor
end

function Verb:AssignObj( obj )
	self.obj = obj
end

function Verb:GetRoomDesc()
	local dc = self:GetDC()
	local desc = self:GetDesc()

	if dc == 0 then
		return desc
	else
		return loc.format( "{1} (DC: {2})", desc, dc )
	end
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

function Verb:GetShortDesc()
	if self.ACT_DESC then
		if self.actor:IsPuppet() then
			return loc.format( self.ACT_DESC[1], self.actor, self.target )
		else
			return loc.format( self.ACT_DESC[3], self.actor, self.target )
		end
	end
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

function Verb:CanCancel()
	return true
end

function Verb:Cancel()
	self.actor:UnassignVerb( self )
	self.actor.world:UnscheduleEvent( self.start_ev )
	self.start_ev = nil
	self.start_duration = nil
	self.start_time = nil
end

function Verb:GetActingProgress()
	if self.start_ev and self.start_duration then
		return 1.0 - (self.start_ev.when - self.actor.world:GetDateTime()) / self.start_duration
	end
end

function Verb:EndActing()
	self.actor:UnassignVerb( self )
	self:Interact( self.actor, self.obj )
	self.start_ev = nil
	self.start_duration = nil
	self.start_time = nil
end

function Verb:__tostring()
	if self.obj then
		return string.format( "<%s : %s>", self._classname, tostring(self.obj))
	else
		return string.format( "<%s>", self._classname )
	end
end
