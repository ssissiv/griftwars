local Token = class( "Token", Entity )

function Token:init( face, count )
	Entity.init( self )
	self.faces = {}
	self:SetFace( face, count )
end

function Token:SetFace( face, count )
	assert( IsEnum( face, DIE_FACE ))
	table.clear( self.faces )
	table.insert( self.faces, face )
	table.insert( self.faces, count )
end

function Token:GetFaceCount( face )
	local idx = table.find( self.faces, face )
	if idx then
		return self.faces[ idx + 1 ]
	end
	return 0
end

function Token:IsCommitted()
	return self.committed == true
end

function Token:CommitToken()
	self.committed = true
end

function Token:__tostring()
	return "[" .. table.concat( self.faces, " " ) .. "]"
end

