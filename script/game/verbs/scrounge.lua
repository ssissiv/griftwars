
local Scrounge = class( "Verb.Scrounge", Verb )

Scrounge.ACT_DESC =
{
	"You are scrounging for some useful things.",
	nil,
	"{1.Id} is here rummaging around.",
}

-- Scrounge.FLAGS = VERB_FLAGS.ATTENTION

function Scrounge:CalculateDC( mods )
	return 10
end

function Scrounge:GetDesc()
	return "Scrounge"
end

function Scrounge:Interact( actor )
	Msg:ActToRoom( "{1.Id} begins rummaging around.", actor )
	Msg:Echo( actor, "You begin to rummage around." )

	self:YieldForTime( HALF_HOUR )
	
	if self:CheckDC() then
		local coins = math.random( 1, 3 )
		Msg:Echo( actor, "You find {1#money}!", coins )
		actor:GetInventory():DeltaMoney( coins )
	else
		Msg:Echo( actor, "You don't find anything useful." )
		Msg:ActToRoom( "{1.Id} mutters something unhappily.", actor )
	end
end
