
local Sleep = class( "Verb.Sleep", Verb )

Sleep.ACT_DESC =
{
	"You are sleeping.",
	nil,
	"{1.Id} is here sleeping.",
}

Sleep.FLAGS = bit32.bor( VERB_FLAGS.ATTENTION, VERB_FLAGS.MOVEMENT, VERB_FLAGS.HANDS )

Sleep.event_handlers =
{
	[ CALC_EVENT.DAMAGE ] = function( self, verb, event_name, acc, actor, target )
		if target == self.actor then
			acc:AddValue( acc.value, "Sleeping" )
		end
	end,
}

function Sleep:GetDesc()
	if self.obj then
		return loc.format( "Sleeping on {1}", self.obj )
	else
		return "Sleeping"
	end
end

function Sleep:CanInteract()
	local actor = self.actor
	if not self:IsDoing() then
		if not actor:IsAlert() then
			return false, "Not Alert"
		end
	end

	if actor:InCombat() then
		return false, "In combat!"
	end

	-- local home = actor:GetLocation():GetAspect( Feature.Home )
	-- if not home or not home:IsResident( actor ) then
	-- 	return false, "This is not your home"
	-- end

	return true
end

function Sleep:Interact()
	local actor = self.actor
	Msg:EchoAround( actor, "{1.Id} goes to sleep.", actor )
	if self.obj then
		Msg:EchoTo( actor, "You go to sleep on {1}.", self.obj )
	else
		Msg:EchoTo( actor, "You go to sleep." )
	end
	
	actor:SetMentalState( MSTATE.SLEEPING )

	actor:GetStat( STAT.FATIGUE ):DeltaRegen( -10 )
	actor:GetStat( STAT.HEALTH ):DeltaRegen( 0.5 )

   	self:YieldForTime( Calendar.GetTimeUntilHour( actor.world:GetDateTime(), 6 ), "wall", 3.0 )

	actor:GetStat( STAT.FATIGUE ):DeltaRegen( 10 )
	actor:GetStat( STAT.HEALTH ):DeltaRegen( -0.5 )

	actor:SetMentalState( MSTATE.ALERT )

	if not self:IsCancelled() then
		local stat_xp = actor.world.nexus:Sleep( actor )
		if stat_xp then
			for stat, xp in pairs( stat_xp ) do
				actor:AssignXP( xp, stat )
			end
		end
	end

	Msg:EchoTo( actor, "You awaken." )
	Msg:EchoAround( actor, "{1.Id} wakes up.", actor )
end
