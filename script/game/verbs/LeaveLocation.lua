local LeaveLocation = class( "Verb.LeaveLocation", Verb )

LeaveLocation.COLOUR = constants.colours.MAGENTA

LeaveLocation.FLAGS = VERB_FLAGS.MOVEMENT

LeaveLocation.ACT_DESC =
{
	"You are travelling through here.",	
	nil,
	"{1.Id} is heading towards {2.title}.",
}

LeaveLocation.EXIT_STRINGS =
{
	nil, --"You leave {2.title}.",
	nil,
	"{1.Id} leaves to {2.title}.",
}

LeaveLocation.ENTER_STRINGS =
{
	"You enter {2.title}.",
	nil,
	"{1.Id} enters."
}

function LeaveLocation:GetShortDesc( viewer )
	if self.obj then
		if self.actor:IsPuppet() then
			return loc.format( self.ACT_DESC[1], self.actor:LocTable( viewer ), self.obj:LocTable( viewer ))
		else
			return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ), self.obj:LocTable( viewer ))
		end
	else
		if self.actor:IsPuppet() then
			return loc.format( self.ACT_DESC[1], self.actor:LocTable( viewer ) )
		else
			return loc.format( "{1.Id} is here, leaving.", self.actor:LocTable( viewer ) )
		end
	end
end

function LeaveLocation:GetDesc()
	if self.obj then
		return loc.format( "Leave to {1}", self.obj:GetTitle() )
	else
		return "Leave somewhere"
	end
end

function LeaveLocation:CanInteract( actor, obj )
	if actor:IsBusy( VERB_FLAGS.MOVEMENT ) then
		return false, "Moving"
	end
	return self._base.CanInteract( self, actor )
end

function LeaveLocation:Interact( actor )
	Msg:Action( self.EXIT_STRINGS, actor, actor:GetLocation() )

	local dest = self.obj
	assert( dest == nil or is_instance( dest, Location ))
	if dest == nil then
		local dests = {}
		for i, dest in actor.location:Exits() do
			assert( dest ~= actor.location )
			table.insert( dests, dest )
		end

		dest = table.arraypick( dests )
	end

	self:YieldForTime( ONE_MINUTE )

	if self:IsCancelled() then
		return
	end
	
	local prev_location = actor:GetLocation()

	actor:DeltaStat( STAT.FATIGUE, 5 )
	actor:WarpToLocation( dest )

	Msg:Action( self.ENTER_STRINGS, actor, dest )

	-- TODO: Followers don't lose fatigue, or take time to leave.
	local leader = actor:GetAspect( Trait.Leader )
	if leader then
		for i, follower in leader:Followers() do
			if follower:GetLocation() == prev_location then
				follower:WarpToLocation( dest )
			end
		end
	end
end

---------------------------------------------------------------

