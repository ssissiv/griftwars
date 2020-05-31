
AppendEnum( AGENT_EVENT, "STRATEGIZE" )

local Strategize = class( "Verb.Strategize", Verb.Plan )

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
	local assault_pts, defend_pts = {}, {}
	local function IsStrategicPoint( location, depth )
		if location:HasAspect( Feature.StrategicPoint ) then
			if actor:IsEnemy( location ) then
				table.insert( assault_pts, location )
			elseif actor:IsAlly( location ) then
				table.insert( defend_pts, location )
			end
		end
		return depth < 12
	end

	actor.location:Flood( IsStrategicPoint )

	if #assault_pts > 0 and self:GetWorld():Random() > 0.0 then
		return self:GetWorld():ArrayPick( assault_pts )
	else
		return self:GetWorld():ArrayPick( defend_pts )
	end
end

function Strategize:CanInteract( actor )
	return false, "Disabled"
end

function Strategize:Interact( actor )
	while true do
		self:YieldForTime( ONE_MINUTE )

		Msg:Speak( actor, "Hmm... where should this brigade go..." )

		self.target = self:FindStrategicPoint( actor )
		if self.target then
			if actor:IsEnemy( self.target ) then
				Msg:Speak( actor, "We must assault {1}!", self.target )
				Msg:Speak( actor, "{1} must be stopped.", self.target:GetAspect( Aspect.FactionMember ):GetName() )
			elseif self.target == actor.location then
				Msg:Speak( actor, "We will occupy this location." )
			else
				Msg:Speak( actor, "We will occupy {1}.", self.target )
			end
		else
			DBG( actor )
		end

		actor:BroadcastEvent( AGENT_EVENT.STRATEGIZE, self.target )
		actor:RecruitAll()

		self:YieldForTime( HALF_DAY )
	end
end
