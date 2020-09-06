local RecentNoise = class( "StatusEffect.RecentNoise", Aspect.StatusEffect )

RecentNoise.name = "Recent Noise"
RecentNoise.tick_duration = 0.5 * ONE_MINUTE

function RecentNoise:TickStatusEffect()
	self:LoseStacks( 1 )
end


RecentNoise.event_handlers = table.inherit( Aspect.StatusEffect.event_handlers,
{
	[ CALC_EVENT.STAT ] = function( self, agent, event_name, acc, stat )
		if stat == STAT.ALERTNESS then
			acc:AddValue( self.stacks, self )
		end
	end,
})
