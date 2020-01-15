
local Strategize = class( "Verb.Strategize", Verb )

function Strategize:init( actor )
	Strategize._base.init( self, actor )
end

function Strategize:GetDetailsDesc( viewer )
	if viewer:CheckPrivacy( self.owner, PRIVACY.INTENT ) then
		return "Making military plans"
	else
		return "???"
	end
end

function Strategize:CalculateUtility( actor )
	return UTILITY.OBLIGATION
end

function Strategize:Interact( actor )
	Msg:Speak( actor, "Hmm... where should this brigade go..." )
end
