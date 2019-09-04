class( "DialogEdge" )

-- parent: DialogNode
-- to: DialogNode
function DialogEdge:init( parent, to )
	self.parent = parent
	self.to = to
	self.reqs = {}
	assert( to )
end

-- face: DIE_FACE
-- max_count: integer (number of faces required to satisfy req)
function DialogEdge:ReqFace( face, max_count )
	table.insert( self.reqs, { type = DLG_REQ.FACE_COUNT, face = face, max_count = max_count })
	return self
end

function DialogEdge:Reqs()
	return ipairs( self.reqs )
end

function DialogEdge:IsSatisfied()
	for i, req in ipairs( self.reqs ) do
		if not self:IsReqSatisfied( req ) then
			return false
		end
	end
	
	return true
end

function DialogEdge:IsReqSatisfied( req )
	if req.type == DLG_REQ.FACE_COUNT and self.parent:GetFaceCount( req.face ) < req.max_count then
		return false
	end

	return true
end

function DialogEdge:RenderObject( ui, viewer )
	for i, req in ipairs( self.reqs ) do
		if req.type == DLG_REQ.FACE_COUNT then
			local txt = loc.format( "[{1}] : {2}/{3} {4}", self.to:GetName(), self.parent:GetFaceCount( req.face ), req.max_count, req.face )
			if not self:IsReqSatisfied( req ) then
				ui.TextColored( 0.5, 0.5, 0.5, 1, txt )

			elseif ui.Selectable( txt ) then
				self.parent:DeactivateNode()
				self.to:ActivateNode()
			end
		end
	end
end


