---------------------------------------------------------------
-- Traits used only by the Player agent.

local Player = class( "Aspect.Player", Aspect )

Player.TABLE_KEY = "player"

Player.event_handlers =
{
	[ ENTITY_EVENT.COMBAT_STARTED ] = function( self, event_name, entity, ... )
		self:SetIntent( SetBits( self.intent, INTENT.HOSTILE ))
	end,

	[ ENTITY_EVENT.COMBAT_ENDED ] = function( self, event_name, entity, ... )
		self:SetIntent( ClearBits( self.intent, INTENT.HOSTILE ))
	end,
}

function Player:init()
	self.intent = INTENT.DIPLOMACY
end

function Player:GetIntent()
	return self.intent
end

function Player:SetIntent( intent )
	if intent ~= self.intent then
		assert(type(intent) == "number")
		self.intent = intent
		self.owner:BroadcastEvent( AGENT_EVENT.INTENT_CHANGED, intent )
	end
end

function Player:CollectVerbs( verbs, actor, obj )
	if self.owner == actor and obj == actor then
		verbs:AddVerb( Verb.Wait())

		if self.owner:GetStat( STAT.FATIGUE ):GetThreshold() >= FATIGUE.TIRED then
			verbs:AddVerb( Verb.Sleep() )
		end

	elseif is_instance( obj, Agent ) then
		verbs:AddVerb( Verb.Follow( obj, 4 ))
	end
end

function Player:OnLocationChanged( prev, location )
	if location then
		location:Discover( self.owner )
	end
end
