local ScroungeTarget = class( "Aspect.ScroungeTarget", Aspect )

function ScroungeTarget:CollectVerbs( verbs, actor, obj )
	local scrounge = actor:GetAspect( Verb.Scrounge )
	if scrounge and obj == self.owner then
		verbs:AddVerb( scrounge )
	end
end

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

function Scrounge:CanInteract( actor, target )
	if not self:IsDoing() then
		if actor:IsBusy( self.FLAGS ) then
			return false, "Busy"
		end
	end

	if not target or not target:GetAspect( Aspect.ScroungeTarget ) then
		return false, "Can't scrounge"
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

		local finder = self:GetRandomActor()
		if self:CheckDC() then
			local coins = math.random( 1, 3 )
			Msg:Echo( finder, "You find {1#money}!", coins )
			finder.world.nexus:LootMoney( finder, coins )
		else
			Msg:Echo( finder, "You don't find anything useful." )
			Msg:ActToRoom( "{1.Id} mutters something unhappily.", finder )
		end

		actor:GainXP( 1 )
		
		if math.random() < 0.5 then
			break
		end
	end
end
