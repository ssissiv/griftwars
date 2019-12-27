local Job = class( "Job", Aspect )

function Job:init( employer )
	assert( is_instance( employer, Agent ))
	self.employer = employer
	self:RegisterHandler( AGENT_EVENT.COLLECT_VERBS, self.OnCollectVerbs )
end

function Job:GetLocation()
	error( tostring(self) ) -- Define location for job.
end

function Job:OnGainAspect( owner )
	Aspect.OnGainAspect( self, owner )

	owner:Acquaint( self.employer )
	self.employer:Acquaint( owner )

	local behaviour = owner:GetAspect( Aspect.Behaviour )
	if behaviour then
		behaviour:RegisterVerb( Verb.WorkJob( owner, self ))
	end

	self:GetWorld():SchedulePeriodicFunction( ONE_HOUR, self.PaySalary, self )
end

function Job:PaySalary()
	local salary = 20
	self.owner:GetInventory():DeltaMoney( salary )
	Msg:Echo( self.owner, "You get an e-transfer from {1.Id} for your job as {2}: {3#money}",
		self.employer:LocTable( self.owner ), self:GetName(), salary )
end

function Job:TrainingReqs()
	return pairs( self.training_reqs or table.empty )
end

function Job:AddTrainingReq( req )
	if self.training_reqs == nil then
		self.training_reqs = {}
	end
	table.insert( self.training_reqs, req )
end

function Job:Clone()
	local clone = setmetatable( table.shallowcopy( self ), self._class )
	clone.owner = nil -- Not transferrable.
	return clone
end

function Job:GetName()
	return self.name or self._classname
end

function Job:OnCollectVerbs( event_name, actor, verbs )
	verbs:AddVerb( Verb.WorkJob( actor, self ))
end
