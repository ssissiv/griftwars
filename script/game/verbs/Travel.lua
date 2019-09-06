local Travel = class( "Verb.Travel", Verb )

Travel.COLOUR = constants.colours.MAGENTA
Travel.VERB_DURATION = 1 * ONE_MINUTE

Travel.ACT_DESC =
{
	"You are traveling through here.",	
	nil,
	"{1.name} is here, heading towards {1#test}.",
}

Travel.EXIT_STRINGS =
{
	"You leave {2.title}.",
	nil,
	"{1.name} leaves.",
}

Travel.ENTER_STRINGS =
{
	"You enter {2.title}.",
	nil,
	"{1.name} enters."
}

function Travel.CollectInteractions( actor, verbs )
	if actor.location then
		for i, exit in actor.location:Exits() do
			table.insert( verbs, Verb.Travel( actor, exit:GetDest( actor.location ) ))
		end
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

