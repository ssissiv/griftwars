local Travel = class( "Verb.Travel", Verb )

Travel.FLAGS = VERB_FLAGS.MOVEMENT


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

function Travel:GetDesc()
	return loc.format( "Travel to {1}", self.obj:GetTitle() )
end

function Travel:Interact( actor )
	local pather = PathFinder( actor, self.obj )
	while actor:GetLocation() ~= pather:GetEndRoom() do
		local path = pather:CalculatePath()
		if path then
			Msg:Action( self.EXIT_STRINGS, actor, path[2] )
			self:YieldForTime( ONE_MINUTE )
			actor:WarpToLocation( path[2] )
			Msg:Action( self.ENTER_STRINGS, actor, path[2] )
		end
	end
end

---------------------------------------------------------------

