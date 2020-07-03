
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
	self.travel = Verb.Travel( actor, obj.actor )
end

function Help:GetDesc()
	return "Help"
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

	self.obj:AddHelperVerb( self )

	while true do
		self:DoChildVerb( self.travel )

		self:YieldForTime( 1 * ONE_MINUTE, "rate", 2.0 )

		if self:IsCancelled() then
			Msg:Echo( actor, "You stop helping." )
			break
		end
	end

	self.obj:RemoveHelperVerb( self )
end

