local StatusEffect = class( "Aspect.StatusEffect", Aspect )

StatusEffect.event_handlers =
{
	[ AGENT_EVENT.DIED ] = function( self, event_name, agent, ... )
		agent:LoseAspect( self )
	end,
}

function StatusEffect:GetDesc( viewer )
	if (self.stacks or 0) > 1 then
		return loc.format( "{1} x{2}", self.name or self._classname, self.stacks )
	else
		return loc.format( "{1}", self.name or self._classname )
	end
end

function StatusEffect:OnSpawn( world )
	Aspect.OnSpawn( self, world )
	if self.tick_duration then
		assert( self.TickStatusEffect )
		self.tick_ev = world:SchedulePeriodicFunction( 0, self.tick_duration, self.TickStatusEffect, self )
	end
	self.ticks = self.max_ticks or 1
	self.stacks = 0
end

function StatusEffect:OnDespawn()
	Aspect.OnDespawn( self )
	self:GetWorld():UnscheduleEvent( self.tick_ev )
	self.tick_ev = nil
end

function StatusEffect:GainStacks( delta )
	self.stacks = self.stacks + delta

	if self.max_stacks then
		self.stacks = math.min( self.stacks, self.max_stacks )
	end
end

function StatusEffect:LoseStacks( delta )
	self.stacks = self.stacks - delta

	if self.stacks <= 0 then
		if self.OnExpireStatusEffect then
			self:OnExpireStatusEffect()
		end
		
		self.owner:LoseAspect( self )
	end
end

function StatusEffect:RenderDebugPanel( ui, panel, dbg )
	local txt = loc.format( "{1} (duration: {2#duration})", self._classname, self.tick_duration or 0 )
	ui.Text( txt )
end
