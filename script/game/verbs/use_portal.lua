local UsePortal = class( "Verb.UsePortal", Verb )

UsePortal.COLOUR = constants.colours.MAGENTA
UsePortal.EXIT_STRINGS =
{
	"You leave {2.title}.",
	nil,
	"{1.name} leaves.",
}

UsePortal.ENTER_STRINGS =
{
	"You enter {2.title}.",
	nil,
	"{1.name} enters."
}

function UsePortal:GetDesc()
	return loc.format( "Leave to {1}", self.obj:GetTitle() )
end

function UsePortal:Interact( actor )
	Msg:Action( self.EXIT_STRINGS, actor, actor:GetLocation() )

	actor:MoveToLocation( self.obj )
	
	Msg:Action( self.ENTER_STRINGS, actor, self.obj )
end

---------------------------------------------------------------

