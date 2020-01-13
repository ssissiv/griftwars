
local Help = class( "Verb.Help", Verb )

Help.ACT_DESC =
{
	"You are helping {1.Id} perform {2}.",
	nil,
	"{1.Id} is here helping {2.Id}.",
}

function Help:init( actor, obj )
	Verb.init( self, actor, obj )
	assert( is_instance, obj, Verb )
	self.travel = self:AddChildVerb( Verb.Travel( actor, obj.actor ))
end

function Help:GetDesc()
	return "Help"
end

function Help:GetDetailsDesc( viewer )
	if viewer:CanSee( self.actor ) then
		return "Busy helping"
	end
end


function Help:GetShortDesc( viewer )
	if viewer == self.actor then
		return loc.format( self.ACT_DESC[1], self.obj.actor:LocTable( viewer ), self.obj )
	else
		return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ), self.obj.actor:LocTable( viewer ) )
	end
end

function Help:CanInteract( actor )
	if not self:IsDoing() then
		if actor:IsBusy( self.FLAGS ) then
			return false, "Busy"
		end
	end

	return self._base.CanInteract( self, actor )
end

function Help:Interact( actor )
	Msg:Echo( actor, "You begin to help {1.Id} out.", self.obj.actor:LocTable( actor ) )

	self.obj:AddChildVerb( self )

	while true do
		self.travel:DoVerb( actor )

		self:YieldForTime( 1 * ONE_MINUTE )

		if actor:IsPuppet() then
			self.ACT_RATE = self.obj.actor:CalculateTimeSpeed()
			self:GetWorld():RefreshTimeSpeed()
		end

		if self:IsCancelled() then
			Msg:Echo( actor, "You stop helping." )
			break
		end
	end
end

