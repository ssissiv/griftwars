local Challenge = class( "Verb.Challenge", Verb )

function Challenge:init( actor )
	Verb.init( self, actor )
	self.duration = 1.0
	self.fns = {}
	self.results = {}
	self.attempts = 1
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

function Challenge:SetAttempts( attempts )
	self.attempts = attempts
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
	if self.start_time == nil then
		self.start_time = now
	end
	return clamp( (now - self.start_time) / self.duration, 0, 1.0 )
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

	love.graphics.setColor( 0, 5, 50 )
	love.graphics.rectangle( "fill", cx - w/2, cy - h/2, w, h )

	local now = love.timer.getTime()
	local t = self:GetT()

	local barw, barh = w - 30, 30
	local x1, x2 = cx - barw/2, cx + barw/2
	local idx = 1
	local x = x1
	while x < x2 do
		local t1, t2 = (x - x1) / (x2 - x1), (x + 10 - x1) / (x2 - x1)
		if t >= t1 and t <= t2 then
			if self.stop_time then
				local c = clamp( (now - self.stop_time) / 0.25, 0, 1 )
				love.graphics.setColor( Lerp( 0, 255, c ), 255, 255 )
			else
				love.graphics.setColor( 0, 255, 255 )
			end

		elseif self:FindResult( t1 ) or self:FindResult( t2 ) then
			if idx % 2 == 1 then
				love.graphics.setColor( 128, 128, 10 )
			else
				love.graphics.setColor( 156, 156, 10 )
			end
		else
			if idx % 2 == 1 then
				love.graphics.setColor( 128, 10, 10 )
			else
				love.graphics.setColor( 156, 10, 10 )
			end
		end
		love.graphics.rectangle( "fill", x, cy + barh/2, 10, barh )
		if t >= t1 and t <= t2 then
			if self.stop_time then
				local c = clamp( (now - self.stop_time) / 0.25, 0, 1 )
				love.graphics.setColor( Lerp( 0, 255, c ), 255, 255, 100 )
			else
				love.graphics.setColor( 0, 250, 250, 100 )
			end
			love.graphics.rectangle( "fill", x - 2, cy + barh/2 - 2, 14, barh + 4 )
		end

		idx = idx + 1
		x = x + 10
	end

	if t >= 1.0 then
		self.start_time = now
		self.attempts = self.attempts - 1
		if self.attempts <= 0 then
			self.result = "fail"
		end
	end
	local x = cx - barw/2 + t * barw
	love.graphics.setColor( 255, 0, 0 )
	love.graphics.line( x, cy + barh/2 + 10, x, cy - barh/2 - 10 )

	if self.stop_time and now - self.stop_time > 0.35 then
		self.result = self:FindResult( self.stop_t ) or "done"
	end
end


