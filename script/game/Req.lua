local Req = class( "Req" )

function Req:init()
	self.type = DLG_REQ.NULL
end

function Req.MakeFaceReq( face, max_count )
	local req = Req()
	req.type = DLG_REQ.FACE_COUNT
	req.face = face
	req.max_count = max_count
	return req
end

function Req:IsSatisfied( viewer )
	if self.type == DLG_REQ.FACE_COUNT then
		local tokens = viewer:GetAspect( Aspect.TokenHolder )
		local count = tokens and tokens:GetFaceCount( self.face )
		if count and count < self.max_count then
			return false, loc.format( "Requires {1} (x{2}) (have {3})", tostring(self.face), self.max_count, count )
		end
	else
		error()
	end

	return true
end


function Req:__tostring()
	return string.format( "[REQ: %s*%s]", tostring(self.face), self.max_count )
end


