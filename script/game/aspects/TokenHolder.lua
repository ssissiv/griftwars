---------------------------------------------------------------
-- Container for tokens.

local TokenHolder = class( "Aspect.TokenHolder", Aspect )

function TokenHolder:init()
	self.tokens = {}
	self.commited_tokens = {}
	self.max_tokens = 3
	self:AddToken( Token( DIE_FACE.DIPLOMACY, 1 ) )
end

function TokenHolder:Tokens()
	return ipairs( self.tokens )
end

function TokenHolder:GetTokenAt( idx )
	return self.tokens[ idx ]
end

function TokenHolder:AddToken( token )
	assert( is_instance( token, Token ))
	table.insert( self.tokens, token )
end

function TokenHolder:GetTokenCount()
	return #self.tokens, self.max_tokens
end

function TokenHolder:CommitReqTokens( reqs )
	local tokens = {}
	reqs = table.shallowcopy( reqs )
	
	-- Create a map of tokens to requirements they satisfy.
	for i, req in ipairs( reqs ) do
		if req.type == DLG_REQ.FACE_COUNT then
			for i, token in ipairs( self.tokens ) do
				if not token:IsCommitted() and token:GetFaceCount( req.face ) >= req.max_count then
					--
					if tokens[ token ] == nil then
						tokens[ token ] = { token }
					end
					table.insert( tokens[ token ], req )
				end
			end
		end
	end

	local sorted_tokens = table.copykeys( tokens )
	table.sort( sorted_tokens, function( a, b ) return #tokens[ a ] > #tokens[ b ] end )

	for i, token in ipairs( sorted_tokens ) do
		token:CommitToken()
		for i, req in ipairs( tokens[ token ] ) do
			table.arrayremove( reqs, req )
		end
		if #reqs == 0 then
			break
		end
	end

	assert( #reqs == 0 ) -- Otherwise, our tokens could not satisfy it, and why are we here?
end

function TokenHolder:GetFaceCount( face )
	local count = 0
	for i, token in ipairs( self.tokens ) do
		if not token:IsCommitted() then
			count = count + token:GetFaceCount( face )
		end
	end
	return count
end

