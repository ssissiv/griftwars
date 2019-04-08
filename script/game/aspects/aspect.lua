local Aspect = class( "Aspect" )


function Aspect:GetID()
	return self._classname
end

function Aspect:CreateVerb( verb_class, actor, obj )
	if self.verb == nil then
		assert( is_class( verb_class, Verb ))
		self.verb = verb_class( actor, obj )
	else
		self.verb:AssignActor( actor )
		self.verb:AssignObj( obj )
	end
	return self.verb
end

function Aspect:OnGainAspect( obj )
	if is_instance( obj, Agent ) then
		self.agent = obj
	else
		self.owner = obj
	end
end

function Aspect:OnLoseAspect( obj )
	self.agent = nil
	self.owner = nil
end
