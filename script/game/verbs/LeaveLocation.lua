local LeaveLocation = class( "Verb.LeaveLocation", Verb )

LeaveLocation.COLOUR = constants.colours.MAGENTA
LeaveLocation.VERB_DURATION = 1 * ONE_MINUTE

LeaveLocation.ACT_DESC =
{
	"You are travelling through here.",	
	nil,
	"{1.Id} is heading towards {2.title}.",
}

LeaveLocation.EXIT_STRINGS =
{
	"You leave {2.title}.",
	nil,
	"{1.Id} leaves.",
}

LeaveLocation.ENTER_STRINGS =
{
	"You enter {2.title}.",
	nil,
	"{1.Id} enters."
}

function LeaveLocation.CollectInteractions( actor, verbs )
	if actor.location then
		for i, exit in actor.location:Exits() do
			local dest = exit:GetDest( actor.location )
			assert( dest ~= actor.location )
			table.insert( verbs, Verb.LeaveLocation( actor, dest ))
		end
	end
end

function LeaveLocation:GetShortDesc( viewer )
	if self.actor:IsPuppet() then
		return loc.format( self.ACT_DESC[1], self.actor:LocTable( viewer ), self.obj and self.obj:LocTable( viewer ))
	else
		return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ), self.obj and self.obj:LocTable( viewer ))
	end
end

function LeaveLocation:GetDesc()
	return loc.format( "Leave to {1}", self.obj:GetTitle() )
end

function LeaveLocation:Interact( actor )
	Msg:Action( self.EXIT_STRINGS, actor, actor:GetLocation() )

	actor:WarpToLocation( self.obj )

	Msg:Action( self.ENTER_STRINGS, actor, self.obj )
end

---------------------------------------------------------------

