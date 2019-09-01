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
	table.insert( self.reqs, { type = DLG_REQ.FACE_COUNT, face = face, count = 0, max_count = max_count })
	return self
end

function DialogEdge:SatisfyFace( face )
	for i, req in ipairs( self.reqs ) do
		if req == DLG_REQ.FACE_COUNT and face == req.face then
			req.count = math.min( req.max_count, req.count + 1 )
		end
	end
end

function DialogEdge:IsSatisfied()
	for i, req in ipairs( self.reqs ) do
		if req == DLG_REQ.FACE_COUNT and req.count < req.max_count then
			return false
		end
	end
	
	return true
end

function DialogEdge:UpdateDialog( dt )
	self.to:UpdateDialog( dt )
end

function DialogEdge:RenderObject( ui, viewer )
	for i, req in ipairs( self.reqs ) do
		if req.type == DLG_REQ.FACE_COUNT then
			if req.count >= req.max_count then
				ui.PushStyleColor( ui.Style_Button, 0, 0, 0, 1 )
			end

			ui.Text( loc.format( "  {1}/{2} {3}", req.count, req.max_count, req.face ))

			if req.count >= req.max_count then
				ui.PopStyleColor()
			end
		end
	end
end


