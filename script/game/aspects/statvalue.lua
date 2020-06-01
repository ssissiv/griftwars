local StatValue = class( "Aspect.StatValue", Aspect )

function StatValue:init( stat, value, max_value )
	assert( value )
	self.stat = stat
	self.value = value
	self.max_value = max_value
end

function StatValue:GetID()
	return self.stat
end

function StatValue:OnSpawn( world )
	world:RegisterStatValue( self )
end

function StatValue:OnDespawn()
	self.owner.world:UnregisterStatValue( self )
end

function StatValue:OnGainAspect( owner )
	Aspect.OnGainAspect( self, owner )
	assert( owner.stats[ self.stat ] == nil )
	owner.stats[ self.stat ] = self
end

function StatValue:OnLoseAspect( owner )
	Aspect.OnLoseAspect( self, owner )
	assert( owner.stats[ self.stat ] == self )
	owner.stats[ self.stat ] = nil
end

function StatValue:SetThresholds( thresholds )
	self.thresholds = thresholds
end

function StatValue:GetThreshold()
	if self.thresholds then
		for i = #self.thresholds, 1, -1 do
			local t = self.thresholds[i]
			if self.value >= t.value then
				return t.id, t.name
			end
		end
	end
end

function StatValue:DeltaValue( delta, max_delta )
	if max_delta then
		self:SetValue( self.value + delta, self.max_value + max_delta )
	else
		self:SetValue( self.value + delta )
	end
end

function StatValue:GetValue()
	return self.value, self.max_value
end

function StatValue:SetValue( value, max_value )
	if max_value then
		self.max_value = max_value
	end

	local new_value
	if self.max_value then
		new_value = math.max( 0, math.min( self.max_value, value ))
	else
		new_value = math.max( 0, value )
	end

	if new_value ~= self.value then
		self.value = new_value
		if IsEnum( self.stat, CORE_STAT ) then
			Msg:Echo( self.owner, "Your {1} is now {2}!", self.stat, self.value )
		end
	end	
end

function StatValue:GetPercent()
	if self.max_value then
		return self.value / self.max_value
	else
		return 0
	end
end

function StatValue:DeltaRegen( regen )
	self.regen_delta = (self.regen_delta or 0) + regen
	self.regen_value = 0
end

function StatValue:Regen( dt )
	if self.regen_delta then
		self.regen_value = self.regen_value + self.regen_delta * dt
		local delta = math.floor( self.regen_value )
		if delta ~= 0 then
			self.regen_value = self.regen_value - delta
			self:DeltaValue( delta )
		end
	end
end

function StatValue:SetGrowthRate( rate )
	self.growth_rate = rate
end

function StatValue:GetGrowthRate()
	return self.growth_rate
end

function StatValue:GetGrowth()
	return self.growth or 0
end

function StatValue:CalculateValueWithXP( xp )
	local growth = math.floor( self.growth_rate * xp + (self.growth or 0))
	local delta = 0
	local xp_next = 100 * 2 ^ (self.value - 1)
	while growth > xp_next do
		growth = growth - xp_next
		delta = delta + 1
		xp_next = 100 * 2 ^ (self.value - 1 + delta)
	end
	local percent = delta + growth / xp_next
	return self.value + delta, growth, percent
end

function StatValue:GainXP( xp )
	local value, new_growth = self:CalculateValueWithXP( xp )
	self.growth = new_growth
	if value ~= self.value then
		self:DeltaValue( value - self.value )
	end
end

function StatValue:RenderAgentDetails( ui, screen )
	local value, max_value = self:GetValue()
	local stat = self.stat
	if max_value then
		ui.Text( loc.format( "{1}: {2}/{3}", stat, value, max_value ))
	else
		ui.Text( loc.format( "{1}: {2}", stat, value ))
	end
end


function StatValue:RenderDebugPanel( ui, panel, dbg )
	self:RenderAgentDetails( ui, panel )

	if ui.IsItemHovered() then
		local threshold, name = self:GetThreshold()
		if threshold then
			ui.SetTooltip( loc.format( "Threshold: {1}", name or threshold))
		end
	end

	if self.regen_delta then
		ui.SameLine( 0, 10 )
		ui.TextColored( 0, 1, 0, 1, string.format( "%+.2f", self.regen_delta ))
	end

	ui.SameLine( 200 )
	if ui.Button( "+" ) then
		self.owner:DeltaStat( stat, Input.IsShift() and 10 or 1 )
	end

	ui.SameLine( 0, 5 )
	if ui.Button( "-" ) then
		self.owner:DeltaStat( stat, Input.IsShift() and -10 or -1 )
	end

	ui.SameLine( 0, 15 )
	if ui.Button( "?" ) then
		DBG(self)
	end
end

function StatValue:__tostring()
	return string.format( "%s[%s:%d]", self._classname, self.stat, self.value )
end

