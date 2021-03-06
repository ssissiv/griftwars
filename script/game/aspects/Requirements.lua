local Requirements = class( "Aspect.Requirements", Aspect )

function Requirements:init()
	self.reqs = {}
end

function Requirements:AddReq( req )
	table.insert( self.reqs, req )
end

function Requirements:HasReqByClass( class )
	for i, req in ipairs( self.reqs ) do
		if is_instance( req, class ) then
			return req
		end
	end
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
			if not reason then
				return false -- No reason, total failure.
			end

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

function Requirements:RenderDebugPanel( ui, panel, dbg, actor )
	for i, req in ipairs( self.reqs ) do
		ui.Bullet()
		if actor then
			ui.Text( req:GetDesc( actor ))
		else
			panel:AppendTable( ui, req )
		end
	end
end
