
local Interaction = class( "Aspect.Interaction", Aspect )

function Interaction:init( actor )
	self.reqs = {}
end

function Interaction:GetDesc()
	return tostring(self)
end

function Interaction:GetToolTip()
	local tt = {}
	for i, req in ipairs( self.reqs ) do
		tt[i] = tostring(req)
	end
	tt = table.concat( tt, ", " )
	return tt
end

function Interaction:IsCooldown()
	return self.cooldown_ev ~= nil
end

function Interaction:GetCooldown()
	if self.cooldown_ev then
		return self.owner.world:GetEventTimeLeft( self.cooldown_ev )
	else
		return 0
	end
end

function Interaction:StartCooldown( cooldown )
	self.cooldown_ev = self.owner.world:ScheduleFunction( cooldown, self.StopCooldown, self )
end

function Interaction:StopCooldown()
	self.cooldown_ev = nil
end

-- face: DIE_FACE
-- max_count: integer (number of faces required to satisfy req)
function Interaction:ReqFace( face, max_count )
	table.insert( self.reqs, Req.Face( face, max_count ))
	return self
end

function Interaction:ReqTrust( trust )
	table.insert( self.reqs, Req.Trust( trust ))
	return self
end

function Interaction:Req( req )
	table.insert( self.reqs, req )
end

function Interaction:Reqs()
	return ipairs( self.reqs )
end

function Interaction:GetFaceCount( face, viewer )
	local count = 0
	local tokens = viewer:GetAspect( Aspect.TokenHolder )
	if tokens then
		count = count + tokens:GetFaceCount( face )
	end
	return count
end

function Interaction:SatisfyReqs( actor )
	local tokens = actor:GetAspect( Aspect.TokenHolder )
	if tokens then
		tokens:CommitReqTokens( self )
	end

	if not self.can_repeat then
		if self.satisfied_by == nil then
			self.satisfied_by = {}
		end
		table.insert( self.satisfied_by, actor )
	end
end

function Interaction:CollectVerbs( verbs, actor, obj )
	if actor ~= self.owner and obj == self.owner and not self.owner:IsDead() then
		local ok, reason = self:CanInteract( actor )
		if ok or reason then
			verbs:AddVerb( Verb.Interact( actor, self ))
		end
	end
end

function Interaction:CanInteract( actor )
	if self:IsCooldown() then
		return false, loc.format( "Cooldown: {1#realtime}", self:GetCooldown() )
	end

	if self.satisfied_by and table.contains( self.satisfied_by, actor ) then
		return false -- "Already satisfied"
	end

	if not actor:IsAdjacent( self.owner ) then
		return false, "Too far away"
	end

	if self.owner:IsBusy( VERB_FLAGS.ATTENTION ) then
		return false, loc.format( "{1.Id} is busy.", self.owner:LocTable( actor ))
	end

	local reasons
	for i, req in ipairs( self.reqs ) do
		local ok, reason = req:IsSatisfied( actor )
		if not ok then
			if reasons == nil then
				reasons = {}
			end
			table.insert( reasons, reason or tostring(req) )
		end
	end
	if reasons then
		return false, table.concat( reasons, "\n" )
	end

	return true
end

function Interaction:RenderTooltip( ui, viewer )
	for i, req in ipairs( self.reqs ) do
		if req.type == DLG_REQ.FACE_COUNT then
			local txt = loc.format( "[{1}] : {2}/{3} {4}", tostring(viewer), self:GetFaceCount( req.face, viewer ), req.max_count, req.face )
			if not req:IsSatisfied( viewer ) then
				ui.TextColored( 0.5, 0.5, 0.5, 1, txt )
			else
				ui.Text( txt )
			end
		end
	end
end
------------------------------------------

local RevealObject = class( "Interaction.RevealObject", Interaction )

function RevealObject:init( class_name, range )
	Interaction.init( self )
	self.range = range
	self.class_name = class_name
end

function RevealObject:Interact( actor )
	local location = self.owner:GetHome() or actor:GetLocation()
	local candidates = location:SearchObject( function( obj ) return is_instance( obj, self.class_name ) end, self.range )
	local obj = table.arraypick( candidates )
	if obj then
		Msg:EchoTo( actor, "{1.Id} reveals the location of {2.Id}.", self.owner:LocTable( actor ), obj:LocTable( actor ) )
		actor:GetMemory():AddEngram( Engram.DiscoverLocation( obj ))
	else
		Msg:EchoTo( actor, "{1.Id} reveals nothing of interest.", self.owner:LocTable( actor ) )
	end
end



-----------------------------------------------------------------------------------

local GiftObject = class( "Interaction.GiftObject", Interaction )

function GiftObject:init( obj )
	Interaction.init( self )
	self.obj = obj
end

function GiftObject:Interact( actor )
	if self.obj then
		Msg:Speak( self.owner, "Here you go, friend" )
		actor:GetInventory():AddItem( self.obj )
		self.obj = nil
	else
		Msg:Speak( self.owner, "Sorry, I have nothing for you." )
	end
end


-----------------------------------------------------------------------------------

local TrainSkill = class( "Interaction.TrainSkill", Interaction )

function TrainSkill:init( skill )
	assert( skill )
	Interaction.init( self )
	self.skill = skill
	for i, req in skill:TrainingReqs() do
		self:Req( req )
	end
end

function TrainSkill:CanInteract( actor )
	if actor:HasAspect( self.skill._class ) then
		return false, "Already known."
	end

	local ok, reason = self.skill:CanLearnSkill( actor )
	if not ok then
		return reason
	end

	return TrainSkill._base.CanInteract( self, actor )
end

function TrainSkill:Interact( actor )
	self:SatisfyReqs( actor )

	Msg:EchoTo( actor, "{1.Desc} teaches you the {2} skill!", self.owner:LocTable( actor ), self.skill:GetName() )
	Msg:EchoAround( actor, "{I.Desc} learns the {2} skill!", actor, self.skill:GetName() )

	actor:GainAspect( self.skill:Clone() )

	self:StartCooldown( 3 * ONE_HOUR )
end

-----------------------------------------------------------------------------------

local OfferJob = class( "Interaction.OfferJob", Interaction )

function OfferJob:init( job )
	assert( is_instance( job, Job ), tostring(job))
	OfferJob._base.init( self )
	self.job = job
	for i, req in job:TrainingReqs() do
		self:Req( req )
	end
end

function OfferJob:CanInteract( actor )
	if self.job.owner == actor then
		return false, "Already has this job."
	elseif self.job.owner then
		return false, loc.format( "This job is already taken by {1.Id}", self.job.owner:LocTable() )
	end

	if not actor:IsAcquainted( self.owner ) then
		return "Not acquainted"
	end
	
	for i, req in self.job:TrainingReqs() do
		local ok, reason = req:IsSatisfied( actor )
		if not ok then
			return false, reason or "Training requirements"
		end
	end

	return OfferJob._base.CanInteract( self, actor )
end

function OfferJob:Interact( actor )
	local title = loc.format( "{1.Id}'s Job Offer", self.owner:LocTable( actor ) )
	local body = loc.format( "Job: {1}\nDo you want to accept the job offer?", self.job:GetName() )

	if self:GetWorld().nexus:ConfirmChoice( title, body ) then
		self:SatisfyReqs( actor )
	
		Msg:EchoTo( actor, "{1.Id} gives you a new job: {2}", self.owner:LocTable( actor ), self.job:GetName() )
		Msg:EchoAround( actor, "{I.Id} gives {2} a new job.", self.owner, actor )

		actor:GainAspect( self.job )
	end
end



