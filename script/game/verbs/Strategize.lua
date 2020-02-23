
AppendEnum( AGENT_EVENT, "STRATEGIZE" )

local Strategize = class( "Verb.Strategize", Verb )

function Strategize:init( actor )
	Strategize._base.init( self, actor )
end

function Strategize:RenderAgentDetails( ui, screen, viewer )
	ui.Bullet()
	if self.target then
		ui.Text( loc.format( "Strategizing to capture {1}", self.target ))
		ui.SameLine( 0, 5 )
		if ui.SmallButton( "?" ) then
			DBG(self.target)
		end
	else
		ui.Text( "Making military plans" )
	end
end

function Strategize:CalculateUtility( actor )
	return UTILITY.OBLIGATION
end

function Strategize:FindStrategicPoint( actor )
	local pts = {}
	local function IsStrategicPoint( location, depth )
		if location:HasAspect( Feature.StrategicPoint ) then
			if not actor:IsAlly( location ) then
				table.insert( pts, location )
			end
		end
		return depth < 12
	end

	actor.location:Flood( IsStrategicPoint )

	return table.arraypick( pts )
end

function Strategize:Interact( actor )
	while true do
		self:YieldForTime( ONE_MINUTE )

		Msg:Speak( actor, "Hmm... where should this brigade go..." )

		self.target = self:FindStrategicPoint( actor )
		if self.target then
			Msg:Speak( actor, "We must target {1}!", self.target )
		end

		actor:BroadcastEvent( AGENT_EVENT.STRATEGIZE, self.target )
		actor:RecruitAll()

		self:YieldForTime( ONE_HOUR )
	end
end
