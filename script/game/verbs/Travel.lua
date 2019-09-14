local Travel = class( "Verb.Travel", Verb )

Travel.COLOUR = constants.colours.MAGENTA
Travel.VERB_DURATION = 1 * ONE_MINUTE

Travel.ACT_DESC =
{
	"You are traveling through here.",	
	nil,
	"{1.Id} is heading towards {2.title}.",
}

Travel.EXIT_STRINGS =
{
	"You leave {2.title}.",
	nil,
	"{1.Id} leaves.",
}

Travel.ENTER_STRINGS =
{
	"You enter {2.title}.",
	nil,
	"{1.Id} enters."
}

function Travel.CollectInteractions( actor, verbs )
	if actor.location then
		for i, exit in actor.location:Exits() do
			local dest = exit:GetDest( actor.location )
			assert( dest ~= actor.location )
			table.insert( verbs, Verb.Travel( actor, dest ))
		end
	end
end

function Travel:GetShortDesc( viewer )
	if self.actor:IsPuppet() then
		return loc.format( self.ACT_DESC[1], self.actor:LocTable( viewer ), self.obj and self.obj:LocTable( viewer ))
	else
		return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ), self.obj and self.obj:LocTable( viewer ))
	end
end

function Travel:GetDesc()
	return loc.format( "Leave to {1}", self.obj:GetTitle() )
end

function Travel:Interact( actor )
	Msg:Action( self.EXIT_STRINGS, actor, actor:GetLocation() )

	actor:MoveToLocation( self.obj )

	Msg:Action( self.ENTER_STRINGS, actor, self.obj )
end

---------------------------------------------------------------

