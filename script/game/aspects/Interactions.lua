local Interaction = class( "Interaction", Aspect )

function Interaction:init()
	self.reqs = {}
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
	table.insert( self.reqs, { type = DLG_REQ.FACE_COUNT, face = face, max_count = max_count })
	return self
end

function Interaction:Reqs()
	return ipairs( self.reqs )
end

function Interaction:GetFaceCount( face, dice )
	local count = 0
	for i, dice in dice:Dice() do
		local f, c = dice:GetRoll()
		if f == face then
			count = count + c
		end
	end
	return count
end

function Interaction:IsSatisfied( dice )
	for i, req in ipairs( self.reqs ) do
		if not self:IsReqSatisfied( req, dice ) then
			return false
		end
	end
	
	return true
end

function Interaction:IsSatisfiable( dice )
	for j, req in ipairs( self.reqs ) do
		local found = false
		if req.type == DLG_REQ.FACE_COUNT then
			if is_instance( dice, DiceContainer ) then
				for i, die in dice:Dice() do
					local face = die:GetRoll()
					if (face == req.face) or (face == nil and die:HasFace( req.face )) then
						found = true
						break
					end
				end

			elseif is_instance( dice, ActionDie ) then
				local face = dice:GetRoll()
				if (face == req.face) or (face == nil and dice:HasFace( req.face )) then
					found = true
					break
				end

			else
				error()
			end
		end
		if not found then
			-- No dice can satisify our reqs!
			return false
		end
	end
	
	return true
end

function Interaction:IsReqSatisfied( req, dice )
	if req.type == DLG_REQ.FACE_COUNT and self:GetFaceCount( req.face, dice ) < req.max_count then
		return false
	end

	return true
end

function Interaction:SatisfyReqs( actor )
	local dice = actor:GetDice()

	for i, req in ipairs( self.reqs ) do
		if req.type == DLG_REQ.FACE_COUNT then
			local count = req.max_count
			-- FIXME: want to take the "optimal" dice
			while count > 0 do
				local found = false
				for i, die in dice:Dice() do
					local face, pips = die:GetRoll()
					if face == req.face then
						count = count - pips
						found = true
						actor:GetDice():CommitDice( die, self.owner )
						break
					end
				end
				if not found then
					break
				end
			end
		end
	end

	self:OnSatisfied( actor )
end

function Interaction:RenderObject( ui, viewer )
	for i, req in ipairs( self.reqs ) do
		if req.type == DLG_REQ.FACE_COUNT then
			local txt = loc.format( "[{1}] : {2}/{3} {4}", self.to:GetName(), self:GetFaceCount( req.face ), req.max_count, req.face )
			if not self:IsReqSatisfied( req ) then
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

function Acquaint:init()
	Acquaint._base.init( self )
	self:ReqFace( DIE_FACE.DIPLOMACY, 1 )
end

function Acquaint:OnSatisfied( actor, dice )
	-- We know the actor.
	actor:GetMemory():AddEngram( Engram.MakeKnown( self.owner, PRIVACY.ID ))
	self.owner:RegenerateLocTable( actor )

	Msg:Speak( "Yo, I'm {1.name}", self.owner, actor )

	self.owner:LoseAspect( self )
end


-----------------------------------------------------------------------------------

local Chat = class( "Interaction.Chat", Interaction )

function Chat:CanInteract( actor )
	if self:IsCooldown() then
		return false, "On Cooldown"
	end

	if not actor:CheckPrivacy( self.owner, PRIVACY.ID ) then
		return false, "Not Acquainted"
	end

	return true
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

	local skill= actor:GainAspect( Skill.Scrounge() )
	Msg:Act( self.owner, actor, "{1.Id} teaches you the {2} skill!", self.owner:LocTable( actor ), skill:GetName() )

	self:StartCooldown( ONE_DAY )
end
