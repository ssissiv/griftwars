
local Sleep = class( "Verb.Sleep", Verb )

Sleep.ACT_DESC =
{
	"You are sleeping.",
	nil,
	"{1.Id} is here sleeping.",
}

Sleep.FLAGS = bit32.bor( VERB_FLAGS.ATTENTION, VERB_FLAGS.MOVEMENT, VERB_FLAGS.HANDS )

function Sleep:GetDesc()
	return "Sleep"
end

function Sleep.CollectInteractions( agent, verbs )
	local home = agent:GetLocation():GetAspect( Feature.Home )
	if home and home:GetHomeOwner() == agent then
		verbs:AddVerb( Verb.Sleep( agent ))
	end
end

function Sleep:CanInteract( actor )
	if not actor:IsAlert() then
		return false, "Not Alert"
	end
	if actor:IsBusy() then
		return false, "Busy"
	end
	return true
end

function Sleep:Interact( actor )
	Msg:ActToRoom( "{1.Id} goes to sleep.", actor )
	Msg:Echo( actor, "You go to sleep." )
	
	if actor:IsPuppet() then
		actor.world:SetWorldSpeed( actor.world:GetWorldSpeed() * SLEEP_SPEED_RATE )
	end

	actor:SetMentalState( MSTATE.SLEEPING )
	actor:GetStat( STAT.FATIGUE ):DeltaRegen( -1 )

   	self:YieldForTime( 1 ) --Calendar.GetTimeUntilHour( actor.world:GetDateTime(), 6 ) )

	if actor:IsPuppet() then
		actor.world:SetWorldSpeed( actor.world:GetWorldSpeed() / SLEEP_SPEED_RATE )
	end

	actor:GetStat( STAT.FATIGUE ):DeltaRegen( 1 )
	actor:SetMentalState( MSTATE.ALERT )

	local stat_xp = actor.world.nexus:Sleep( actor )
	if stat_xp then
		for stat, xp in pairs( stat_xp ) do
			actor:AssignXP( xp, stat )
		end
	end

	Msg:Echo( actor, "You awaken." )
	Msg:ActToRoom( "{1.Id} wakes up.", actor )
end
