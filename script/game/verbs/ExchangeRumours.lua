
local ExchangeRumours = class( "Verb.ExchangeRumours", Verb )
ExchangeRumours.VERB_DURATION = ONE_HOUR / 4

ExchangeRumours.LESSER_MSG =
{
	"You shoot the fat with {2.name}, sniffing out useful pieces of info.",
	"{1.name} hails you. You shoot the fat, sniffing out useful pieces of info.",
	"{1.name} is here chatting up {2.name}.",
}
ExchangeRumours.MORE_MSG =
{
	"You shoot the fat with {2.name}, sniffing out info. You learn a lot.",
	"{1.name} hails you. You shoot the fat and learn a lot.",
	"{1.name} is here chatting up {2.name}.",
}
ExchangeRumours.NONE_MSG =
{
	"You shoot the fat with {2.name}, but there is nothing to be learned.",
	"{1.name} hails you. You shoot the fat but nothing interesting comes up.",
	"{1.name} is here chatting up {2.name}.",
}

function ExchangeRumours.CollectInteractions( actor, verbs )
	if actor.location and actor:HasAspect( Skill.RumourMonger ) then
		for i, obj in actor.location:Contents() do
			if actor:GetFocus() == obj and obj:GetFocus() == actor and obj:HasAspect( Skill.RumourMonger ) then
				table.insert( verbs, Verb.ExchangeRumours( actor, obj ))
			end
		end
	end
end

function ExchangeRumours:GetDesc()
	return "Exchange Rumours"
end

function ExchangeRumours:Interact( actor, obj )
	local actor_count = actor:GetStat( STAT.RUMOURS )
	local obj_count = obj:GetStat( STAT.RUMOURS )

	if actor_count > obj_count then
		obj:DeltaStat( STAT.RUMOURS, math.min( actor_count - obj_count, 3 ))
		actor:DeltaStat( STAT.RUMOURS, 1 )
		Msg:Action( self.LESSER_MSG, actor, obj )

	elseif actor_count == obj_count then
		Msg:Action( self.NONE_MSG, actor, obj )

	else
		obj:DeltaStat( STAT.RUMOURS, 1 )
		actor:DeltaStat( STAT.RUMOURS, math.min( obj_count - actor_count, 3 ))
		Msg:Action( self.MORE_MSG, actor, obj )
	end
end

