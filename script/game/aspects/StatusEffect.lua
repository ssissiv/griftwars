local StatusEffect = class( "Aspect.StatusEffect", Aspect )

function StatusEffect:GetDesc( viewer )
	if (self.ticks or 0) > 1 then
		return loc.format( "{1} x{2}", self.name or self._classname, self.ticks )
	else
		return loc.format( "{1}", self.name or self._classname )
	end
end

function StatusEffect:OnSpawn( world )
	if self.tick_duration then
		self.tick_ev = world:SchedulePeriodicFunction( 0, self.tick_duration, self.TickStatusEffect, self )
	end
	self.ticks = self.max_ticks or 1
end

function StatusEffect:OnDespawn()
	self:GetWorld():UnscheduleEvent( self.tick_ev )
	self.tick_ev = nil
end

function StatusEffect:TickStatusEffect()
	if self.OnTickStatusEffect then
		self:OnTickStatusEffect()
	end

	self.ticks = self.ticks - 1
	if self.ticks <= 0 then
		if self.OnExpireStatusEffect then
			self:OnExpireStatusEffect()
		end
		
		self.owner:LoseAspect( self )
	end
end

function StatusEffect:RenderDebugPanel( ui, panel, dbg )
	local txt = loc.format( "{1} (tick: {2}/{3}, duration: {4#duration})", self._classname, self.ticks, self.max_ticks, self.tick_duration or 0 )
	ui.Text( txt )
end
