require "game/dialog_nodes/DialogBase"

class( "DialogEdge", DialogBase )

function DialogEdge:SetDirectional( from, to )
	self.from = from
	self.to = to
	self.reqs = {}
end

function DialogEdge:AddReq( face, count )
	table.insert( self.reqs, { type = DLG_REQ.FACE_COUNT, face = face, count = 0, max_count = max_count })
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

