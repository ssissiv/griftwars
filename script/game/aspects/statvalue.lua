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

function StatValue:DeltaValue( delta )
	if self.max_value then
		self.value = math.min( self.max_value, self.value + delta )
	else
		self.value = self.value + delta
	end
end

function StatValue:GetValue()
	return self.value, self.max_value
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

