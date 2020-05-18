local Requirements = class( "Aspect.Requirements", Aspect )

function Requirements:init()
	self.reqs = {}
end

function Requirements:AddReq( req )
	table.insert( self.reqs, req )
end

function Requirements:HasReq( fn )
	for i, req in ipairs( self.reqs ) do
		if fn( req ) then
			return req
		end
	end
end

function Requirements:IsSatisfied( actor )
	local reasons
	for i, req in ipairs( self.reqs ) do
		local ok, reason = req:IsSatisfied( actor )
		if not ok then
			if reasons == nil then
				reasons = {}
			end
			table.insert( reasons, reason or tostring(req) )
		end
	end
	if reasons then
		return false, table.concat( reasons, "\n" )
	end

	return true
end

