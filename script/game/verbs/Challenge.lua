local Challenge = class( "Verb.Challenge", Verb )

function Challenge:init( actor )
	Verb.init( self, actor )
	self.fns = {}
	self.duration = 1.0
	self.results = {}
	self.attempts = 0
	self.max_attempts = 1

	self:Reset()
end

function Challenge:Reset()
	self.attempts = 0
	self.result = nil
	self.stop_time = nil
	self.stop_t = nil
	self.start_time = nil
end

function Challenge:GetResult()
	return self.result
end

function Challenge:SetName( name )
	self.name = name
	return self
end

function Challenge:SetDuration( duration )
	self.duration = duration
	return self
end

function Challenge:SetAttempts( max_attempts )
	self.max_attempts = max_attempts
	return self
end

function Challenge:AddFunction( fn )
	table.insert( self.fns, fn )
	return self
end

function Challenge:AddResult( t1, t2, result )
	table.insert( self.results, { t1 = t1, t2 = t2, result = result })
	return self
end

function Challenge:FindResult( t )
	for i, v in ipairs( self.results ) do
		if v.t1 <= t and v.t2 >= t then
			return v.result
		end
	end 
end

function Challenge:Interact( actor, target )
	local result = actor.world.nexus:RollChallenge( self, actor, target )

	print ("Challenge result:" )
	if result then
	end

end

function Challenge:GetT()
	if self.stop_t then
		return self.stop_t
	end

	local now = love.timer.getTime()
	if not self.start_time then
		return 0
	else
		return clamp( (now - self.start_time) / self.duration, 0, 1.0 )
	end
end

function Challenge:Start()
	self.start_time = love.timer.getTime()
end

function Challenge:IsStarted()
	return self.start_time ~= nil
end

function Challenge:Cancel()
	self.result = "cancel"
end

function Challenge:Stop()
	if self.stop_time == nil then
		self.stop_time = love.timer.getTime()
		self.stop_t = self:GetT()
	end
end

function Challenge:RenderImGuiWindow( ui, screen )

	local screenw, screenh = love.graphics.getWidth(), love.graphics.getHeight()
	local cx, cy = screenw/2, screenh*0.5
	local w, h = screenw*0.7, screenh/4

	love.graphics.setColor( 0, 0, 0 )
	love.graphics.rectangle( "fill", cx - w/2 - 8, cy - h/2 - 8, w + 18, h + 18 )
	love.graphics.setColor( 0, 5, 50 )
	love.graphics.rectangle( "fill", cx - w/2, cy - h/2, w, h )

	local now = love.timer.getTime()
	local t = self:GetT()

	local barw, barh = w - 30, 30
	local bar_hoffset = 50
	local x1, x2 = cx - barw/2, cx + barw/2
	local idx = 1
	local xcell
	local x = x1
	while x < x2 do
		local t1, t2 = (x - x1) / (x2 - x1), (x + 10 - x1) / (x2 - x1)
		if t >= t1 and t <= t2 then
			if self.stop_time then
				local result = self:FindResult( self.stop_t ) or "done"
				local tc = clamp( (now - self.stop_time) / 1.0, 0, 1 )
				local c = Easing.outQuad( tc, 0, 255, 1.0 )
				if result == "done" then
					love.graphics.setColor( 255 - c, 0, 0 )
				else
					love.graphics.setColor( c, 255, c )
				end
			else
				love.graphics.setColor( 0, 255, 255 )
			end

		elseif self:FindResult( t1 ) or self:FindResult( t2 ) then
			if idx % 2 == 1 then
				love.graphics.setColor( 0, 128, 10 )
			else
				love.graphics.setColor( 0, 156, 10 )
			end
		else
			if idx % 2 == 1 then
				love.graphics.setColor( 96, 10, 10 )
			else
				love.graphics.setColor( 64, 10, 10 )
			end
		end
		local dh = 1.0
		for i, fn in ipairs( self.fns ) do
			dh = dh * fn( (t1 + t2) / 2 )
		end
		dh = dh * barh

		screen:Rectangle( x, cy + bar_hoffset - barh/2 - dh, 9, barh + dh )
		if screen:IsHovered() then
			local result = self:FindResult( t1 ) or self:FindResult( t2 ) 
			if result then
				screen:SetTooltip( tostr(result)) 
			else
				screen:SetTooltip( "FAIL" )
			end
		end

		if t >= t1 and t <= t2 then
			xcell = x
		end

		idx = idx + 1
		x = x + 10
	end

	if xcell then
		if self.stop_time then
			local result = self:FindResult( self.stop_t ) or "done"
			local tc = clamp( (now - self.stop_time) / 1.0, 0, 1 )
			local c = Easing.outQuad( tc, 0, 255, 1.0 )
			local a = Easing.linear( tc, 100, -100, 1.0 )
			local sz = Easing.outCubic( tc, 0, 20, 1.0 )
			if result == "done" then
				love.graphics.setColor( 255 - c, 0, 0, math.floor(a) )
			else
				love.graphics.setColor( c, 255, c, math.floor(a) )
			end
			love.graphics.rectangle( "fill", xcell - 2 - sz/2, cy + bar_hoffset - barh/2 - 2 - sz/2, 14 + sz, barh + 4 + sz )
		else
			love.graphics.setColor( 0, 250, 250, 100 )
			love.graphics.rectangle( "fill", xcell - 2, cy + bar_hoffset - barh/2 - 2, 14, barh + 4 )
		end
	end

	-- Attempts Remaining
	love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.setFont( assets.FONTS.TITLE )
    if self.start_time == nil then
		love.graphics.print( "Press ENTER to go, or any other key to cancel", cx - w/2 + 10, cy - h/2 )
	else
		love.graphics.print( loc.format( "Attempts left: {1}", self.attempts ), cx - w/2 + 10, cy - h/2 )

		-- Check loop.
		if t >= 1.0 then
			self.start_time = now
			self.attempts = self.attempts + 1
			if self.max_attempts <= self.attempts then
				self.result = "fail"
			end
		end

		-- Post-delay.
		if self.stop_time and now - self.stop_time > 1 and self.result == nil then
			self.result = self:FindResult( self.stop_t ) or "done"
		end
	end
end


