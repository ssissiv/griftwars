local Interaction = class( "Interaction", Aspect )

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

function Interaction:Reqs()
	return ipairs( self.reqs )
end

function Interaction:GetFaceCount( face, viewer )
	local count = 0
	local dice = viewer:GetDice()
	if dice then
		for i, dice in dice:Dice() do
			local f, c = dice:GetRoll()
			if f == face then
				count = count + c
			end
		end
	end

	local tokens = viewer:GetAspect( Aspect.TokenHolder )
	if tokens then
		count = count + tokens:GetFaceCount( face )
	end
	return count
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

	if self.satisfied_by == nil then
		self.satisfied_by = {}
	end
	table.insert( self.satisfied_by, actor )

	self:OnSatisfied( actor )
end

function Interaction:CanInteract( actor )
	if self:IsCooldown() then
		return false, loc.format( "Cooldown: {1#realtime}", self:GetCooldown() )
	end

	if self.satisfied_by and table.contains( self.satisfied_by, actor ) then
		return false -- Already satisfied
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

local Acquaint = class( "Interaction.Acquaint", Interaction )

function Acquaint:init( cr )
	Acquaint._base.init( self )
	self:ReqFace( DIE_FACE.DIPLOMACY, math.random( 1, cr ) )
end

function Acquaint:CanInteract( actor )
	if self.owner:IsBusy( VERB_FLAGS.ATTENTION ) then
		return false, loc.format( "{1.Id} is busy.", self.owner:LocTable( actor ))
	end

	return Acquaint._base.CanInteract( self, actor )
end

function Acquaint:OnSatisfied( actor, dice )
	-- We know the actor.
	if actor:Acquaint( self.owner ) then
		Msg:Speak( "Yo, I'm {1.name}", self.owner, actor )
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

function Chat:OnSatisfied( actor, dice )
	Msg:Speak( "There's lots of stuff to find if you know where to look.", self.owner, actor )

	local die = ActionDie( "Local Chat",
	{
		DIE_FACE.DIPLOMACY, 1,
		DIE_FACE.DIPLOMACY, 1,
		DIE_FACE.DIPLOMACY, 1,
		DIE_FACE.DISTRICT_MIDGARD, 1,
		DIE_FACE.DISTRICT_MIDGARD, 1,
		DIE_FACE.DISTRICT_MIDGARD, 1,
	})
	actor:GetDice():AddDie( die )

	local skill = actor:GainAspect( Skill.Scrounge() )
	Msg:Act( self.owner, actor, "{1.Id} teaches you the {2} skill!", self.owner:LocTable( actor ), skill:GetName() )

	self:StartCooldown( ONE_DAY )
end


-----------------------------------------------------------------------------------
-- TODO: have Shopkeep own this implementation

local BuyFromShop = class( "Interaction.BuyFromShop", Interaction, Verb )

function BuyFromShop:init()
	self:init_bases()
	assert( self.reqs )
end

-- Verb.GetDesc
function BuyFromShop:GetDesc()
	return "Buy/Sell"
end

function BuyFromShop:CanInteract( actor )
	if self.owner:IsBusy() then
		return false, loc.format( "{1.Id} is busy.", self.owner:LocTable( actor ))
	end

	return true
end

function BuyFromShop:OnSatisfied( actor, dice )
	actor:DoVerb( self )
end

function BuyFromShop:Interact( actor )
	assert( actor )
	-- local item = self.owner:GetInventory():GetRandomItem()
	local item = actor.world.nexus:ChooseBuyItem( self.owner, actor )
	if item then
		self.owner:GetAspect( Aspect.Shopkeep ):SellToBuyer( item, actor )
	end
end

-----------------------------------------------------------------------------------
-- Learn about Relationship

local LearnRelationship = class( "Interaction.LearnRelationship", Interaction )

function LearnRelationship:CanInteract( actor )
	return not self.owner:HasAgent( actor ) and not self.owner:IsKnownBy( actor )
end

function LearnRelationship:OnSatisfied( actor, dice )
	self.owner:AddKnownBy( actor )
end




