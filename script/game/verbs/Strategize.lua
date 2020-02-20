
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

function Strategize:FindStrategicPoint( actor )
	local pts = {}
	local function IsStrategicPoint( location, depth )
		if location:HasAspect( Feature.StrategicPoint ) then
			table.insert( pts, location )
		end
		return depth < 12
	end

	actor.location:Flood( IsStrategicPoint )

	DBG(pts)
end

function Strategize:Interact( actor )
	while true do
		self:YieldForTime( ONE_HOUR )
		Msg:Speak( actor, "Hmm... where should this brigade go..." )

		self.target = self:FindStrategicPoint( actor )
	end
end
