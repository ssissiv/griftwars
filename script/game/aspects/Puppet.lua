---------------------------------------------------------------
-- Traits used only by the Puppet agent.

local Puppet = class( "Aspect.Puppet", Aspect )

Puppet.TABLE_KEY = "puppet"

Puppet.event_handlers =
{
	[ ENTITY_EVENT.COMBAT_STARTED ] = function( self, event_name, entity, ... )
		self:SetIntent( SetBits( self.intent, INTENT.HOSTILE ))
	end,

	[ ENTITY_EVENT.COMBAT_ENDED ] = function( self, event_name, entity, ... )
		self:SetIntent( ClearBits( self.intent, INTENT.HOSTILE ))
	end,
}

function Puppet:init()
	self.intent = INTENT.DIPLOMACY
end

function Puppet:GetIntent()
	return self.intent
end

function Puppet:OnSpawn( world )
	Aspect.OnSpawn( self, world )
	if self.owner:InCombat() then
		self:SetIntent( SetBits( self.intent, INTENT.HOSTILE ))
	end
end

function Puppet:SetIntent( intent )
	if intent ~= self.intent then
		assert(type(intent) == "number")
		self.intent = intent
		self.owner:BroadcastEvent( AGENT_EVENT.INTENT_CHANGED, intent )
	end
end

function Puppet:CollectVerbs( verbs, actor, obj )
	if self.owner == actor and obj == actor then
		verbs:AddVerb( Verb.Wait())

		if self.owner:GetStat( STAT.FATIGUE ):GetThreshold() >= FATIGUE.TIRED then
			verbs:AddVerb( Verb.Sleep() )
		end

	elseif is_instance( obj, Agent ) then
		verbs:AddVerb( Verb.Follow( obj, 4 ))
	end
end

function Puppet:OnLocationChanged( prev, location )
	if location then
		location:Discover( self.owner )
	end
end
