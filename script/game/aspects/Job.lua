local Job = class( "Job", Verb )

function Job:init( employer )
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
	return loc.format( "Work job as {1}", self:GetName() )
end

function Job:GetShortDesc( viewer )
	if viewer == self:GetOwner() then
		return "You are working."
	else
		return loc.format( "{1.Id} is here working.", self:GetOwner():LocTable( viewer ))
	end
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

function Job:GetLocation()
	error( tostring(self) ) -- Define location for job.
end

function Job:CalculateUtility()
	local world = self:GetWorld()
	if self:IsTimeForShift( world:GetDateTime() ) or self:IsDoing() then
		return UTILITY.OBLIGATION
	else
		return 0
	end
end

function Job:CalculateTimeSpeed()
	local duration = self:GetShiftDuration()
	return 64 * (duration / ONE_DAY)
end


function Job:OnSpawn( world )
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
	if owner:GetLocation() ~= self:GetLocation() then
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
			Msg:Echo( owner, "You generated {3#money} as profit!", salary )
		else
			Msg:Echo( owner, "You get an e-transfer from {1.Id} for your job as {2}: {3#money}",
				self.employer:LocTable( owner ), self:GetName(), salary )
		end
		Msg:ActToRoom( "{1.Id} counts {1.hisher} earnings for the day.", owner )
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

function Job:CollectVerbs( verbs, actor )
	if self and actor == self.owner then
		verbs:AddVerb( self )
	end
end

function Job:CanInteract( actor )
	if not self:IsTimeForShift( self:GetWorld():GetDateTime() ) then
		return false, "Not time for shift"
	end
	return true
end


function Job:Interact()
	local actor = self:GetOwner()
	-- Track job location and stay around there.
	while self:IsTimeForShift( self:GetWorld():GetDateTime() ) do
		if self.travel == nil then
			self.travel = Verb.Travel()
		end
		local job_location = self:GetLocation()
		if job_location and actor:GetLocation() ~= job_location then
			local ok, reason = self.travel:DoVerb( actor, job_location )
			if actor:GetLocation() == self:GetLocation() then
				Msg:Speak( actor, "Time for work!" )
			end
		end

		if actor:GetLocation() == self:GetLocation() then
			if self.DoJob then
				self:DoJob()
			else
				self:YieldForTime( self:GetShiftDuration() )
			end

			if not self:IsCancelled() then
				actor:GainXP( 5 )
				self:PaySalary()
			end

		else
			self:YieldForTime( HALF_HOUR )			
		end
	end

	Msg:Speak( actor, "Clocking out." )
end
