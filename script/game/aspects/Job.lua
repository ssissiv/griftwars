local Job = class( "Job", Verb.Plan )

function Job:init( employer )
	Verb.init( self )
	assert( is_instance( employer, Agent ))
	self.employer = employer

	if self.OnInit then
		self:OnInit()
	end
end

function Job:GetName()
	return self.name or self._classname
end

function Job:GetDesc()
	return loc.format( "Working as {1}", self:GetName() )
end

function Job:RenderAgentDetails( ui, screen )
	local job = self.owner:GetAspect( Job )
	if job then
		ui.Text( "Job:" )
		ui.SameLine( 0, 5 )
		ui.Text( job:GetName() )

		local salary = job:GetSalary()
		if salary then
			ui.Text( "  Salary:" )
			ui.SameLine( 0, 5 )
			ui.TextColored( 0, 1, 0, 1, loc.format( "{1} credits/day", salary ))
		end
		local hire_time = job:GetHireTime()
		if hire_time then
			local now = self.owner.world:GetDateTime()
			ui.Text( loc.format( "  Hired for: {1}", Calendar.FormatDuration( now - hire_time )))
		end
	end
end

function Job:GetWaypoint()
	error( tostring(self) ) -- Define location for job.
end

function Job:CalculateUtility()
	local world = self:GetWorld()
	if self:IsTimeForShift( world:GetDateTime() ) or self:IsDoing() then
		return UTILITY.DUTY
	else
		return 0
	end
end

function Job:CalculateTimeSpeed()
	local duration = self:GetShiftDuration()
	return 64 * (duration / ONE_DAY)
end


function Job:OnSpawn( world )
	self.actor = self.owner
	self.owner:Acquaint( self.employer )
	self.employer:Acquaint( self.owner )
	self.hire_time = self:GetWorld():GetDateTime()
end

function Job:GetHireTime()
	return self.hire_time
end

function Job:GetSalary()
	return self.salary
end

function Job:SetShiftHours( start_time, end_time )
	self.start_time = start_time
	self.end_time = end_time
	assert( self.end_time > self.start_time )
end

function Job:IsTimeForShift( datetime )
	if self.start_time and self.end_time then
		local tod = Calendar.GetTimeOfDay( datetime )
		return tod >= self.start_time and tod < self.end_time
	else
		return true
	end
end

function Job:ShouldDo()
	local owner = self:GetOwner()
	if owner == nil then
		return false, "No worker"
	end
	if not self:IsTimeForShift( self:GetWorld():GetDateTime() ) then
		return false, "Not time for shift"
	end
	local wp = self:GetWaypoint()
	if wp == nil then
		return false, "No job location"
	elseif not wp:AtWaypoint( owner ) then
		return false, "Not at job location"
	end
	return true
end

function Job:GetShiftDuration()
	if self.start_time and self.end_time then
		return self.end_time - self.start_time
	else
		return ONE_DAY
	end
end

function Job:PaySalary( salary )
	if salary == nil then
		salary = self:GetSalary()
	end
	if salary then
		local owner = self:GetOwner()
		owner:GetInventory():DeltaMoney( salary )

		if owner == self.employer then
			Msg:EchoTo( owner, "You generated {3#money} as profit!", salary )
		else
			Msg:EchoTo( owner, "You get an e-transfer from {1.Id} for your job as {2}: {3#money}",
				self.employer:LocTable( owner ), self:GetName(), salary )
		end
		Msg:EchoAround( owner, "{1.Id} counts {1.hisher} earnings for the day." )
	end
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

function Job:CollectVerbs( verbs, actor, obj )
	if actor == self.owner and actor == obj then
		verbs:AddVerb( self )
	end
end

function Job:CanInteract()
	if not self:IsTimeForShift( self:GetWorld():GetDateTime() ) then
		return false, "Not time for shift"
	end
	return true
end

function Job:Idle( actor, duration )
	if self.idle == nil then
		self.idle = Verb.Idle( actor )
	end
	self.idle:SetDuration( duration )

	self:DoChildVerb( self.idle )
end

function Job:Interact()
	local actor = self:GetOwner()
	-- Track job location and stay around there.
	while self:IsTimeForShift( self:GetWorld():GetDateTime() ) and not self:IsCancelled() do
		local waypoint = self:GetWaypoint()
		if waypoint and not waypoint:AtWaypoint( actor ) then
			local ok, reason = self:DoChildVerb( Verb.Travel( actor, waypoint ))
			if ok then
				Msg:Speak( actor, "Time for work!" )
			end
		end

		if self:IsCancelled() then
			break
		end

		if waypoint and waypoint:AtWaypoint( actor ) then
			if not self.DoJob or not self:DoJob() then
				self:Idle( actor, self:GetShiftDuration() )
			end

			if not self:IsCancelled() then
				actor:GainXP( 5 )
				self:PaySalary()
			end

		else
			self:Idle( actor )
		end
	end

	if not self:IsCancelled() then
		Msg:Speak( actor, "Clocking out." )
	end
end
