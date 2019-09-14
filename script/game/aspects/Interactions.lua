local Interaction = class( "Interaction", Aspect )

function Interaction:init()
	self.reqs = {}
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
	for i, dice in ipairs( dice ) do
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
			for i, die in ipairs( dice ) do
				local face = die:GetRoll()
				if (face == req.face) or (face == nil and die:HasFace( req.face )) then
					found = true
					break
				end
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

function Acquaint:SatisfyReqs( actor, dice )
	-- We know the actor.
	actor:GetMemory():AddEngram( Engram.MakeKnown( self.owner, PRIVACY.ID ))
	self.owner:RegenerateLocTable( actor )

	Msg:Speak( "Yo, I'm {1.name}", self.owner, actor )

	self.owner:LoseAspect( self )
end


