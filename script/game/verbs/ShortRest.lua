
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

function ShortRest:CanInteract( actor )
	if not actor:IsAlert() then
		return false, "Not Alert"
	end
	if actor:IsBusy( VERB_FLAGS.MOVEMENT ) then
		return false, "Busy"
	end
	return true
end

function ShortRest:Interact( actor )
	Msg:ActToRoom( "{1.Id} sits down and rests.", actor )
	Msg:Echo( actor, "You sit down and take a load off." )
	
	actor:GetStat( STAT.FATIGUE ):DeltaRegen( -40 )

   	self:YieldForTime( ONE_HOUR )

	actor:GetStat( STAT.FATIGUE ):DeltaRegen( 40 )

	Msg:Echo( actor, "You stop resting." )
	Msg:ActToRoom( "{1.Id} stops resting.", actor )
end
