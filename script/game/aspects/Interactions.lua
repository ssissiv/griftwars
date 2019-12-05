
local Interaction = class( "Aspect.Interaction", Aspect )

function Interaction:init()
	self.reqs = {}
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
	table.insert( self.reqs, Req.MakeFaceReq( face, max_count ))
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

function Interaction:OnCollectVerbs( event_name, agent, verbs )
	if actor:GetFocus() then
		local ok, reason = true
		if self.CanInteract then
			ok, reason = self:CanInteract( agent )
		end
		if ok or reason then
			verbs:AddVerb( Verb.Interact( agent, self ))
		end
	end


					-- 	if is_instance( aspect, Interaction ) then
					-- 		count = count + 1
					-- 		-- if aspect:IsSatisfied( agent ) then
					-- 			local ok, reason = true
					-- 			if aspect.CanInteract then
					-- 				ok, reason = aspect:CanInteract( agent )
					-- 			end
					-- 			if ok or reason then
					-- 				if not ok then
					-- 					ui.PushStyleColor( "Button", 0.2, 0.2, 0.2, 1 )
					-- 				end
					-- 				if ui.Button( aspect._classname ) and ok then
					-- 					aspect:SatisfyReqs( agent )
					-- 				end
end

function Interaction:IsSatisfied( viewer )
	for i, req in ipairs( self.reqs ) do
		if not req:IsSatisfied( viewer ) then
			return false
		end
	end
	
	return true
end

function Interaction:SatisfyReqs( actor )
	local tokens = actor:GetAspect( Aspect.TokenHolder )
	tokens:CommitReqTokens( self )

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
		if not req:IsSatisfied( actor ) then
			if reasons == nil then
				reasons = {}
			end
			table.insert( reasons, tostring(req) )
		end
	end
	if reasons then
		return false, table.concat( reasons, "\n" )
	end

	return true
end

function Interaction:RenderObject( ui, viewer )
	for i, req in ipairs( self.reqs ) do
		if req.type == DLG_REQ.FACE_COUNT then
			local txt = loc.format( "[{1}] : {2}/{3} {4}", self.to:GetName(), self:GetFaceCount( req.face, viewer ), req.max_count, req.face )
			if not req:IsSatisfied( viewer ) then
				ui.TextColored( 0.5, 0.5, 0.5, 1, txt )

			elseif ui.Selectable( txt ) then
				self.parent:DeactivateNode()
				self.to:ActivateNode()
			end
		end
	end
end


-----------------------------------------------------------------------------------

local Interact = class( "Verb.Interact", Verb )

function Interact:init( actor, aspect )
	assert( is_instance( aspect, Aspect.Interaction ))
	Verb.init( self, actor, actor:GetFocus() )
	self.interaction = aspect
end

function Interact:GetDesc()
	return tostring(self.interaction)
end

function Interact.CollectInteractions( actor, verbs )
	local focus = actor:GetFocus()
	if focus then
		for i, aspect in focus:Aspects() do
			if is_instance( aspect, Aspect.Interaction ) then
				local ok, reason = true
				if aspect.CanInteract then
					ok, reason = aspect:CanInteract( actor )
				end
				if ok or reason then
					verbs:AddVerb( Verb.Interact( actor, aspect ))
				end
			end
		end
	end
end

function Interact:CanInteract( actor, ... )
	local ok, reason = self.interaction:CanInteract( actor )
	if not ok then
		return false, reason
	end

	return Verb.CanInteract( self, actor, ... )
end

function Interact:Interact( actor )
	self.interaction:SatisfyReqs( actor )
	self.interaction:Interact( actor )
end

function Interact:__tostring()
	return string.format( "Interact: %s", tostring(self.interaction))
end

-----------------------------------------------------------------------------------

local Acquaint = class( "Interaction.Acquaint", Interaction )

function Acquaint:init( cr )
	Acquaint._base.init( self )
	self:ReqFace( DIE_FACE.DIPLOMACY, math.random( 1, cr ) )
end

function Acquaint:Interact( actor )
	-- We know the actor.
	if actor:Acquaint( self.owner ) then
		Msg:Speak( self.owner, "Yo, I'm {1.name}", actor )
		actor:CollectPotentialVerbs( true )
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

	for i, req in self.skill:TrainingReqs() do
		local ok, reason = req:IsSatisfied( actor )
		if not ok then
			return false, reason
		end
	end

	return TrainSkill._base.CanInteract( self, actor )
end

function TrainSkill:Interact( actor )
	Msg:Echo( actor, "{1.Id} teaches you the {2} skill!", self.owner:LocTable( actor ), self.skill:GetName() )
	Msg:ActToRoom( "{I.Id{} learns the {2} skill!", actor )

	actor:GainAspect( self.skill:Clone() )

	self:StartCooldown( 3 * ONE_HOUR )
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
		Msg:Speak( self.owner, "There's lots of stuff to find if you know where to look.", actor )

		self.owner:GainAspect( TrainSkill( skill ))

		self:StartCooldown( ONE_DAY )
	else
		Msg:Speak( self.owner, "Nothing to say, really.", actor )
	end
end


-----------------------------------------------------------------------------------
-- TODO: have Shopkeep own this implementation

local BuyFromShop = class( "Interaction.BuyFromShop", Interaction )

BuyFromShop.can_repeat = true -- This interaction can take place multiple times.

function BuyFromShop:Interact( actor )
	assert( actor )
	local item = actor.world.nexus:ChooseBuyItem( self.owner, actor )
	if item then
		self.owner:GetAspect( Aspect.Shopkeep ):SellToBuyer( item, actor )
	end
end

-----------------------------------------------------------------------------------
-- Learn about Relationship

local LearnRelationship = class( "Interaction.LearnRelationship", Interaction )

function LearnRelationship:CanInteract( actor )
	if self.owner:HasAgent( actor ) or self.owner:IsKnownBy( actor ) then
		return false, "Relationship already known"
	end

	return LearnRelationship._base.CanInteract( self, actor )
end

function LearnRelationship:Interact( actor, dice )
	self.owner:AddKnownBy( actor )
end




