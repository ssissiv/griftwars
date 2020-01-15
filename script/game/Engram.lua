local Engram = class( "Engram" )

function Engram:GetAge( owner )
	return owner.world:GetDateTime() - self.when
end

function Engram:StampTime( owner )
	local world = owner.world
	if world then
		self.when = world:GetDateTime()
	end
end
-----------------------------------------------------------------------------
-- You know certain details about an Agent

local MakeKnown = class( "Engram.MakeKnown", Engram )

function MakeKnown:init( agent, pr_flags )
	assert( is_instance( agent, Agent ))
	self.pr_flags = pr_flags
	self.obj = agent
end

function MakeKnown:RenderImGuiWindow( ui, screen, owner )
	if CheckBits( self.pr_flags, PRIVACY.ID ) then
		ui.Text( loc.format( "You learned {1.Id}'s name.", self.obj:LocTable( owner )))
	end
	if CheckBits( self.pr_flags, PRIVACY.LOOKS ) then
		ui.Text( loc.format( "You learned {1.Id}'s looks.", self.obj:LocTable( owner )))
	end
	if CheckBits( self.pr_flags, PRIVACY.HAUNTS ) then
		ui.Text( loc.format( "You learned where {1.Id}'s hangs out.", self.obj:LocTable( owner )))
	end
	if CheckBits( self.pr_flags, PRIVACY.INTENT ) then
		ui.Text( loc.format( "You learned {1.Id}'s plans and intents.", self.obj:LocTable( owner )))
	end
end


-----------------------------------------------------------------------------
-- You know certain details about an Agent

local LearnLocation = class( "Engram.LearnLocation", Engram )

function LearnLocation:init( location )
	assert( is_instance( location, Location ))
	self.location = location
end

function LearnLocation:RenderImGuiWindow( ui, screen, owner )
	ui.Text( loc.format( "You know how to get to {1}.", self.location:GetTitle() ))
end

function Engram.HasLearnedLocation( engram, location )
	return engram._class == LearnLocation and engram.location == location
end

