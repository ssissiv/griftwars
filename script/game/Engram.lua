local Engram = class( "Engram" )

Engram.duration = ONE_DAY

function Engram:MergeEngram( other )
	return false
end

function Engram:GetDesc()
	return self._classname
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

function Engram:Clone()
	return setmetatable( table.shallowcopy( self ), self._class )
end


-----------------------------------------------------------------------------
-- You are making a note about something.  When you see it, it is marked in the UI.

local Marked = class( "Engram.Marked", Engram )

function Marked:init( obj, why )
	self.obj = obj
	self.why = why
end

function Marked:GetDesc()
	return loc.format( "You marked {1} ({2})", self.obj, self.why )
end

function Marked:MergeEngram( other )
	if is_instance( other, Marked ) and self.obj == other.obj then
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

function MakeKnown:GetDesc()
	return loc.format( "You learned about {1.Id}.", self.obj:LocTable( owner ))
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

HasAttacked.duration = ONE_WEEK

function HasAttacked:init( agent )
	assert( is_instance( agent, Agent ))
	self.agent = agent
end

function HasAttacked:GetDesc()
	return loc.format( "{1.Id} attacked you or an ally.", self.agent:LocTable( owner ))
end

function HasAttacked:MergeEngram( other )
	if is_instance( other, HasAttacked ) and self.agent == other.agent then
		self.when = other.when
		return true
	end

	return false
end


-----------------------------------------------------------------------------
-- The agent was befriended recently.

local Befriended = class( "Engram.Befriended", Engram )

Befriended.duration = ONE_DAY

function Befriended.Find( e, by )
	return is_instance( e, Befriended ) and e.by == by
end

function Befriended:init( by )
	assert( is_instance( by, Agent ))
	self.by = by
end

function Befriended:GetDesc()
	return loc.format( "{1.Id} befriended you.", self.by:LocTable( owner ))
end

-----------------------------------------------------------------------------
-- Diplomacy bonus when dealing with this faction.

local InsideInfo = class( "Engram.InsideInfo", Engram )

function InsideInfo:init( faction )
	self.faction = faction
end

function InsideInfo:GetDesc()
	return loc.format( "You have insider information about {1}.", self.faction:GetFactionName() )
end

-----------------------------------------------------------------------------
-- You know the location of something

local Discovered = class( "Engram.Discovered", Engram )

function Discovered:init( target, desc )
	self.target = target
	self.desc = desc
end

function Discovered:MergeEngram( other )
	if is_instance( other, Discovered ) and self.target == other.target then
		self.when = other.when
		return true
	end

	return false
end

function Discovered:CheckPrivacy( target, pr_flags )
	if target == self.target then
		return SetBits( pr_flags, PRIVACY_ALL )
	else
		return pr_flags
	end
end

function Discovered:GetDesc()
	if self.desc then
		return self.desc
	end
	if is_instance( self.target, Location ) then
		return loc.format( "You know how to get to {1}.", self.target:GetTitle() )

	elseif is_instance( self.target, Agent ) then
		local faction = self.target:GetAspect( Aspect.FactionMember )
		if faction then
			local role = faction:GetRole()
			if role then
				return loc.format( "You learn about {1.name}, {2} of {3}.", self.target:LocTable(), role, faction:GetName() )
			else
				return loc.format( "You learn about {1.name}, of {2}.", self.target:LocTable(), faction:GetName() )
			end
		else
			return loc.format( "You know of {1.name}.", self.target:LocTable() )
		end

	else
		return loc.format( "You know of {1}.", self.target )
	end
end

function Discovered:RenderImGuiWindow( ui, screen, viewer )
	if is_instance( self.target, Agent ) then
		local marked = viewer:IsMarked( self.target, "ui" )
		if marked and ui.Button( "Unmark" ) then
			viewer:Unmark( self.target, "ui" )
		elseif not marked and ui.Button( "Mark" ) then
			viewer:Mark( self.target, "ui" )
		end

	elseif is_instance( self.target, Location ) then
		if ui.Button( "Travel To" ) then
			viewer:DoVerbAsync( Verb.Travel( viewer, self.target ))
		end
	end
end
