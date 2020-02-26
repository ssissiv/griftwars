
function Agent:GainTrustedInteractions( t )
	table.shuffle( t )
	for i, v in ipairs( t ) do
		assert( is_instance( v, Aspect.Interaction ))

		v:ReqTrust( i * math.floor( 100 / #t ))
		self:GainAspect( v )
	end
end

local Interaction = class( "Aspect.Interaction", Aspect )

function Interaction:init()
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

function Interaction:CanInteract( actor )
	if self:IsCooldown() then
		return false, loc.format( "Cooldown: {1#realtime}", self:GetCooldown() )
	end

	if self.satisfied_by and table.contains( self.satisfied_by, actor ) then
		return false -- "Already satisfied"
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

-----------------------------------------------------------------------------------

local Befriend = class( "Interaction.Befriend", Interaction )

Befriend.can_repeat = true -- This interaction can take place multiple times.

function Befriend:init()
	Befriend._base.init( self )
	-- self:ReqFace( DIE_FACE.DIPLOMACY, math.random( 1, cr ) )
end

function Befriend:CanInteract( actor )
	local affinity = self.owner:GetAffinity( actor )
	if affinity == AFFINITY.FRIEND then
		return false
	end
	if affinity == AFFINITY.UNFRIEND or affinity == AFFINITY.ENEMY then
		return false, "Doesn't like you"
	end
	if actor:GetMaxFriends() <= actor:CountAffinities( AFFINITY.FRIEND ) then
		return false, "Max friends reached"
	end

	return Interaction.CanInteract( self, actor )
end

function Befriend:Interact( actor )

	local challenge = self.challenge
	if challenge == nil then
		challenge = Verb.Challenge( actor ):SetDuration( 1.0 ):SetAttempts( 3 )
		local t1, t2 = math.random(), math.random()
		challenge:AddResult( t1, t1 + 0.1 * math.random( 1, 3 ), "success" )
		challenge:AddResult( t2, t2 + 0.1 * math.random( 1, 3 ), "success" )
		self.challenge = challenge
	else
		challenge:Reset()
	end

	local result = actor.world.nexus:DoChallenge( challenge )
	if result == "cancel" then

	elseif result == "success" then
		if actor:Befriend( self.owner ) then
			Msg:SpeakTo( self.owner, actor, "Yo, I'm {1.name}", self.owner:LocTable( actor ))
		end
		if self.OnSuccess then
			self:OnSuccess( actor, challenge )
		end
	else
		Msg:Echo( actor, "{1.Id} seems indifferent.", self.owner:LocTable( actor ))
	end
end

-----------------------------------------------------------------------------------

local IntroduceAgent = class( "Interaction.IntroduceAgent", Befriend )

function IntroduceAgent:init( friend )
	Befriend.init( self )
	if is_instance( friend, Agent ) then
		self.friend = friend
	elseif is_class( friend ) then
		self.friend_class = friend
	end
end

function IntroduceAgent:OnSuccess( actor )
	if self.friend == nil and self.friend_class then
		self.friend = actor.world:ArrayPick( actor.world:CreateBucketByClass( self.friend_class ) )
	end

	if self.friend then
		actor:Acquaint( self.friend )
		Msg:Speak( self.owner, "Listen, {1.Id} is a friend of mine. {1.HeShe} can help you out.", self.friend:LocTable( actor ) )

		local work = self.friend:GetAspect( Job )
		if work and work:GetLocation() then
			Msg:Speak( self.owner, "Works over at the {1}.", work:GetLocation():GetTitle() )
		else
			if self.friend:GetHome() then
				Msg:Speak( self.owner, "Lives over at {1}.", self.friend:GetHome():GetLocation():GetTitle() )
			end
		end
	else
		Msg:Speak( self.owner, "Fraid I don't really know anybody." )
	end
end


-----------------------------------------------------------------------------------

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
		Msg:Echo( actor, "{1.Id} reveals the location of {2.Id}.", self.owner:LocTable( actor ), obj:LocTable( actor ) )
		actor:GetMemory():AddEngram( Engram.LearnWhereabouts( obj ))
	else
		Msg:Echo( actor, "{1.Id} reveals nothing of interest.", self.owner:LocTable( actor ) )
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

	Msg:Echo( actor, "{1.Id} teaches you the {2} skill!", self.owner:LocTable( actor ), self.skill:GetName() )
	Msg:ActToRoom( "{I.Id{} learns the {2} skill!", actor )

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
	
		Msg:Echo( actor, "{1.Id} gives you a new job: {2}", self.owner:LocTable( actor ), self.job:GetName() )
		Msg:ActToRoom( "{I.Id} gives {2} a new job.", self.owner, actor )

		actor:GainAspect( self.job )
	end
end

-----------------------------------------------------------------------------------

local Chat = class( "Interaction.Chat", Interaction )

function Chat:CanInteract( actor )
	if not actor:CheckPrivacy( self.owner, PRIVACY.ID ) then
		return false --, "Not Acquainted"
	end

	return Chat._base.CanInteract( self, actor )
end

function Chat:Interact( actor )
	local t = ObtainWorkTable()
	for i, aspect in self.owner:Aspects() do
		if is_instance( aspect, Skill ) then
			table.insert( t, aspect )
		end
	end

	local skill = table.arraypick( t )
	if skill then
		Msg:SpeakTo( self.owner, actor, "There's lots of stuff to find if you know where to look." )

		self.owner:GainAspect( TrainSkill( skill ))

		self:StartCooldown( ONE_DAY )
	else
		Msg:SpeakTo( self.owner, actor, "Nothing to say, really." )
	end
end


-----------------------------------------------------------------------------------
-- TODO: have Shopkeep own this implementation

local BuyFromShop = class( "Interaction.BuyFromShop", Interaction )

BuyFromShop.can_repeat = true -- This interaction can take place multiple times.

function BuyFromShop:CanInteract( actor )
	local job = self.owner:GetAspect( Job.Shopkeep )
	if not job:IsDoing() then
		local ok, reason = job:ShouldDo()
		if not ok then
			return false, reason
		else
			return false, "Not on the job"
		end
	end

	return Interaction.CanInteract( self, actor )
end

function BuyFromShop:Interact( actor )
	assert( actor )
	local item = actor.world.nexus:ChooseBuyItem( self.owner, actor )
	if item then
		self.owner:GetAspect( Job.Shopkeep ):SellToBuyer( item, actor )
	end
end

-------------------------------------------------------------------------

local WantMoney = class( "Interaction.WantMoney", Interaction )

function WantMoney:GetDesc()
	return loc.format( "Give {1.Id} money", self.owner:LocTable() )
end

function WantMoney:CanInteract( actor )
	if actor:GetInventory():GetMoney() < 5 then
		return false, "Not enough credits"
	end

	return WantMoney._base.CanInteract( self, actor )
end

function WantMoney:Interact( actor )
	-- Give money.
	Verb.GiveMoney.Interact( nil, actor, self.owner, 5 )

	-- You've earned Trust!
	local tokens = actor:GetAspect( Aspect.TokenHolder )
	if tokens then
		
	end

	self:StartCooldown( 3 * ONE_HOUR )
end

