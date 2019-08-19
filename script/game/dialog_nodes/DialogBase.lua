class( "DialogBase" )

function DialogBase:init( def, owner_agent )
	self.def = def
	self.owner = owner_agent
	self:Reset()
end

function DialogBase:Reset()
	self.update_tick = 0
	self.visit_count = 0
	self.timer = 0
	self.max_timer = 0
	if self.def.stat_reqs then
		self.stat_reqs = table.deepcopy( self.def.stat_reqs )
	end
end

function DialogBase:GetName()
	return self.def.name
end

function DialogBase:UpdateBase( tick, dt )	
	if edge.update_tick < tick then
		return false
	end

	self.update_tick = tick
	self.timer = self.timer + dt
	
	return true
end

function DialogBase:UpdateNode( tick, dt )
end

function DialogBase:CanReveal( agent )
	if self.revealed then
		return true
	end

	if self.stat_reqs then
		for i, req in ipairs( self.stat_reqs ) do
			local value = agent:GetStat( req.stat_id )
			if req.min_value and value < req.min_value then
				return false, "Insufficient "..req.stat_id
			elseif req.max_value and value > req.max_value then
				return false, "Too much "..req.stat_id
			end
		end
	end

	return true
end

function DialogBase:Reveal( agent )
	self.revealed = true

	if self.def.OnReveal then
		self.def.OnReveal( self )
	end
end


