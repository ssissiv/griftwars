local Activity = class( "Verb.Activity", Verb )

function Activity:GetName()
	return self.name or self._classname
end

function Activity:GetDesc()
	return loc.format( "Activity: {1}", self:GetName() )
end

function Activity:OnSpawn( world )
	self.actor = self.owner
end

function Activity:CollectVerbs( verbs, actor, obj )
	if actor:GetLocation() == self.owner and obj == actor then
		verbs:AddVerb( Verb.Activity( actor ))
	end
end

function Activity:CanInteract()
	-- FindActivity queries Activity before travelling to destination...
	-- if self.actor:GetLocation() ~= self.owner then
	-- 	return false, "not there"
	-- end

	return true
end

function Activity:Idle( duration )
	if self.idle == nil then
		self.idle = Verb.Idle( self.actor )
	end
	self.idle:SetDuration( duration )

	self:DoChildVerb( self.idle )
end

