local DeathLoot = class( "Aspect.DeathLoot", Aspect )

DeathLoot.event_handlers =
{
	[ AGENT_EVENT.DIED ] = function( self, event_name, agent, ... )
		self:SpawnLoot()
		agent:LoseAspect( self )
	end,
}

function DeathLoot:init( t )
	assert( t )
	self.loot_table = t
end

function DeathLoot:SpawnLoot()
	self.loot_table:SpawnLoot( self.owner.inventory, self:GetWorld().rng )
end


