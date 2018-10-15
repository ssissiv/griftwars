local Feature = class( "Feature", Aspect )

function Feature:OnGainAspect( obj )
	assert( is_instance( obj, Location ))
	self.location = obj
end

---------------------------------------------------------------

local Portal = class( "Feature.Portal", Feature )

Portal.EXIT_STRINGS =
{
	"You leave.",
	nil,
	"{1.name} leaves.",
}

Portal.ENTER_STRINGS =
{
	"You enter.",
	nil,
	"{1.name} enters."
}

function Portal:init( dest_location )
	self.dest_location = dest_location
end

function Portal:GetDesc()
	return loc.format( "Leave to {1}", self.dest_location:GetTitle() )
end

function Portal:CanInteract( actor )
	if actor:GetLocation() == self.location then
		return true
	end
	return false
end

function Portal:Interact( actor )
	Msg:Action( self.EXIT_STRINGS, actor )

	actor:MoveToLocation( self.dest_location )
	
	Msg:Action( self.ENTER_STRINGS, actor )
end

---------------------------------------------------------------

