local Engram = class( "Engram" )

Engram.duration = ONE_DAY

function Engram:MergeEngram( other )
	return false
end

function Engram:GetAge( owner )
	return owner.world:GetDateTime() - self.when
end

function Engram:GetDuration()
	return self.duration
end

function Engram:StampTime( owner )
	local world = owner.world
	if world then
		self.when = world:GetDateTime()
	end
end


-----------------------------------------------------------------------------
-- You are making a note about something.  When you see it, it is marked in the UI.

local Marked = class( "Engram.Marked", Engram )

function Marked:init( obj )
	self.obj = obj
end

function Marked:MergeEngram( other )
	if is_instance( other, Marked ) then
		self.when = other.when
		return true
	end

	return false
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
-- The agent has attacked you or an ally.

local HasAttacked = class( "Engram.HasAttacked", Engram )

function HasAttacked:init( agent )
	assert( is_instance( agent, Agent ))
	self.agent = agent
end

function HasAttacked:MergeEngram( other )
	if is_instance( other, HasAttacked ) then
		self.when = other.when
		return true
	end

	return false
end


function HasAttacked:RenderImGuiWindow( ui, screen, owner )
	ui.Text( "{1.Id} attacked you or an ally.", self.agent:LocTable( owner ))
end


-----------------------------------------------------------------------------
-- You know the location of something

local Discovered = class( "Engram.Discovered", Engram )

function Discovered:init( target )
	self.target = target
end

function Discovered:RenderImGuiWindow( ui, screen, owner )
	if is_instance( self.target, Location ) then
		ui.Text( loc.format( "You know how to get to {1}.", self.target:GetTitle() ))
	else
		ui.Text( loc.format( "You know how to get to {1}.", self.target ))
	end
end

Discovered.ACTIONS =
{
	{ name = "Travel", verb = function( self, owner ) return owner:DoVerbAsync( Verb.Travel( self.target )) end }
}
