local ScroungeTarget = class( "Aspect.ScroungeTarget", Aspect )

-------------------------------------------------------------------------

local Scrounge = class( "Verb.Scrounge", Verb )

Scrounge.ACT_DESC =
{
	"You are scrounging for some useful things.",
	nil,
	"{1.Id} is here rummaging around.",
}

Scrounge.ACT_RATE = 8.0

Scrounge.FLAGS = VERB_FLAGS.HANDS

function Scrounge:CalculateDC( mods )
	return 10
end

function Scrounge:GetDesc()
	return "Scrounge"
end

function Scrounge:GetDetailsDesc( viewer )
	if viewer:CanSee( self.owner ) then
		return "Busy scrounging"
	end
end


function Scrounge:GetShortDesc( viewer )
	if viewer == self.actor then
		return loc.format( self.ACT_DESC[1] )
	else
		return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ) )
	end
end


function Scrounge:CanInteract( actor )
	if not self:IsDoing() then
		if actor:IsBusy( self.FLAGS ) then
			return false, "Busy"
		end
	end
	return self._base.CanInteract( self, actor )
end

function Scrounge:Interact( actor )
	Msg:ActToRoom( "{1.Id} begins rummaging around.", actor )
	Msg:Echo( actor, "You begin to rummage around." )

	while true do
		self:YieldForTime( 30 * ONE_MINUTE )
		actor:DeltaStat( STAT.FATIGUE, 5 )

		if self:IsCancelled() then
			break
		end
		
		if self:CheckDC() then
			local obj = actor:GetLocation():GetAspect( Aspect.ScroungeTarget )
			if obj then
				local coins = math.random( 1, 3 )
				Msg:Echo( actor, "You find {1#money}!", coins )
				actor:GetInventory():DeltaMoney( coins )
			else
				Msg:Echo( actor, "You think you see a coin, but it turns out to be chewing gum." )
			end
		else
			Msg:Echo( actor, "You don't find anything useful." )
			Msg:ActToRoom( "{1.Id} mutters something unhappily.", actor )
		end

		actor:GainXP( 1 )
		
		if math.random() < 0.5 then
			break
		end
	end
end
