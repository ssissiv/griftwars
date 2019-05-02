local Travel = class( "Verb.Travel", Verb )

Travel.COLOUR = constants.colours.MAGENTA
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

function Travel:GetDesc()
	return loc.format( "Leave to {1}", self.obj:GetTitle() )
end

function Travel:Interact( actor )
	Msg:Action( self.EXIT_STRINGS, actor, actor:GetLocation() )

	actor:MoveToLocation( self.obj )
	
	Msg:Action( self.ENTER_STRINGS, actor, self.obj )
end

---------------------------------------------------------------

