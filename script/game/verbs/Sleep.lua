
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
	[ CALC_EVENT.DAMAGE ] = function( self, verb, event_name, acc, target )
		if target == self.actor then
			acc:AddValue( acc.value, "Sleeping" )
		end
	end,
}

function Sleep:GetDesc()
	return "Sleep"
end

function Sleep:RenderAgentDetails( ui, screen, viewer )
	if viewer:CanSee( self.owner ) then
		ui.Bullet()
		ui.Text( "Sleeping" )
	end
end

function Sleep:CanInteract( actor )
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

function Sleep:Interact( actor )
	Msg:ActToRoom( "{1.Id} goes to sleep.", actor )
	Msg:Echo( actor, "You go to sleep." )
	
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

	Msg:Echo( actor, "You awaken." )
	Msg:ActToRoom( "{1.Id} wakes up.", actor )
end
