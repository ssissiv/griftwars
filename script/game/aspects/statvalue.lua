local StatValue = class( "Aspect.StatValue", Aspect )

function StatValue:init( stat, value, max_value )
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

function StatValue:DeltaValue( delta, max_delta )
	if max_delta then
		self.max_value = self.max_value + max_delta
	end

	if self.max_value then
		self.value = math.max( 0, math.min( self.max_value, self.value + delta ))
	else
		self.value = math.max( 0, self.value + delta )
	end
end

function StatValue:GetValue()
	return self.value, self.max_value
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

function StatValue:GainXP( xp )
	self.growth = (self.growth or 0) + (self.growth_rate * xp)
	local delta = math.floor( self.growth )
	if delta ~= 0 then
		self.growth = self.growth - delta
		self:DeltaValue( delta, delta )
	end
end

function StatValue:RenderDebugPanel( ui, panel, dbg )
	local value, max_value = self:GetValue()
	local stat = self.stat
	if max_value then
		ui.Text( loc.format( "{1}: {2}/{3}", stat, value, max_value ))
	else
		ui.Text( loc.format( "{1}: {2}", stat, value ))
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
end


