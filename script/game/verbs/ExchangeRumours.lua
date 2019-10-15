
local ExchangeRumours = class( "Verb.ExchangeRumours", Verb )

ExchangeRumours.LESSER_MSG =
{
	"You shoot the fat with {2.id}, sniffing out useful pieces of info.",
	"{1.Id} hails you. You shoot the fat, sniffing out useful pieces of info.",
	"{1.Id} is here chatting up {2.id}.",
}
ExchangeRumours.MORE_MSG =
{
	"You shoot the fat with {2.id}, sniffing out info. You learn a lot.",
	"{1.Id} hails you. You shoot the fat and learn a lot.",
	"{1.Id} is here chatting up {2.id}.",
}
ExchangeRumours.NONE_MSG =
{
	"You shoot the fat with {2.id}, but there is nothing to be learned.",
	"{1.Id} hails you. You shoot the fat but nothing interesting comes up.",
	"{1.Id} is here chatting up {2.id}.",
}

function ExchangeRumours.CollectInteractions( actor, verbs )
	if actor.location and actor:HasAspect( Skill.RumourMonger ) then
		local obj = actor:GetFocus()
		if obj and obj:GetFocus() == actor and obj:HasAspect( Skill.RumourMonger ) then
			table.insert( verbs, Verb.ExchangeRumours( actor, obj ))
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
	if self.actor:GetFocus() ~= self.obj then
		return false, "Requires focus"
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
