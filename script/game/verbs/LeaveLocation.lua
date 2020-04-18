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
		local dest
		if is_instance( self.obj, Aspect.Portal ) then
			dest = self.obj:GetDest()
		else
			dest = self.obj
		end

		if self.actor:IsPuppet() then
			return loc.format( self.ACT_DESC[1], self.actor:LocTable( viewer ), dest:LocTable( viewer ))
		else
			return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ), dest:LocTable( viewer ))
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
	if is_instance( self.obj, Location ) then
		return loc.format( "Leave to {1}", self.obj:GetTitle() )
	elseif is_instance( self.obj, Aspect.Portal ) then
		return loc.format( "Leave to {1}", self.obj:GetDest():GetTitle() )
	else
		return "Leave somewhere"
	end
end

function LeaveLocation:CanInteract()
	for i, verb in self.actor:Verbs() do
		if verb ~= self and verb:HasBusyFlag( VERB_FLAGS.MOVEMENT ) then
			return false, "Moving"
		end
	end
	return self._base.CanInteract( self, self.actor )
end

function LeaveLocation:Interact( actor )
	Msg:Action( self.EXIT_STRINGS, actor, actor:GetLocation() )

	local dest
	if self.obj == nil then
		-- Chose a random accessible portal out of here.
		local dests = {}
		for i, portal in actor.location:Portals() do
			local dest = portal:GetDest()
			assert( dest ~= actor.location )
			table.insert( dests, dest )
		end

		dest = table.arraypick( dests )
		if dest == nil then
			return
		end

	elseif is_instance( self.obj, Aspect.Portal ) then
		dest = self.obj:GetDest()

	elseif is_instance( self.obj, Location ) then
		dest = self.obj

	else
		error(tostring(self.obj))
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

