
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

function ExchangeRumours:SpendCost()
	self.actor:DeltaStat( STAT.CHARISMA, -1 )
end

function ExchangeRumours:CanInteract()
	if self.actor:GetStat( STAT.CHARISMA ) <= 0 then
		return false, "Requires Charisma"
	end
	return true
end


function ExchangeRumours:Interact( actor, obj )

	self:SpendCost()

	if not self:CheckDC() then
		Msg:Action( self.NONE_MSG, actor, obj )
	else
		local learned, revealed = {}, {}
		if actor:GetAspect( Skill.RumourMonger ):ExchangeInfo( obj, learned, revealed ) then
			Msg:Action( self.MORE_MSG, actor, obj )

			for i = 1, #learned, 2 do
				local e_info, delta = learned[i], learned[i+1]
				actor:Echo( loc.format( "Learned: {1} (x{2})", e_info, delta ))
			end

			for i = 1, #revealed, 2 do
				local e_info, delta = revealed[i], revealed[i+1]
				actor:Echo( loc.format( "Revealed: {1} (x{2})", e_info, delta ))
			end

		else
			Msg:Action( self.LESSER_MSG, actor, obj )
		end
	end
end
