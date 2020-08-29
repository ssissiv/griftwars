
local ShortRest = class( "Verb.ShortRest", Verb )

ShortRest.ACT_DESC =
{
	"You are resting.",
	nil,
	"{1.Id} is here resting.",
}

ShortRest.FLAGS = bit32.bor( VERB_FLAGS.MOVEMENT )

function ShortRest:GetDesc()
	return "Short rest"
end

function ShortRest:GetDesc( viewer )
	return "Resting"
end

function ShortRest:CanInteract()
	if not self.actor:IsAlert() then
		return false, "Not Alert"
	end
	if self.actor:IsBusy( VERB_FLAGS.MOVEMENT ) then
		return false, "Busy"
	end
	return true
end

function ShortRest:Interact()
	local actor = self.actor

	Msg:EchoAround( actor, "{1} huffs and puffs.", actor )
	Msg:EchoTo( actor, "You huff and puff." )
	
	actor:GetStat( STAT.FATIGUE ):DeltaRegen( -30 * PER_SHORT_REST )
	actor:GetStat( STAT.HEALTH ):DeltaRegen( -2 * PER_SHORT_REST )

   	self:YieldForTime( SHORT_REST_TIME )

	actor:GetStat( STAT.FATIGUE ):DeltaRegen( 30 * PER_SHORT_REST )
	actor:GetStat( STAT.HEALTH ):DeltaRegen( 2 * PER_SHORT_REST )
end
