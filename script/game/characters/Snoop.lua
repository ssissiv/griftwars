
local FindInformation = class( "Verb.FindInformation", Verb.Plan )

function FindInformation:init()
	FindInformation._base.init( self )
	self.travel = self:AddChildVerb( Verb.Travel())
	self.idle = self:AddChildVerb( Verb.Idle() )
end

function FindInformation:RenderAgentDetails( ui, screen, viewer )
	ui.Bullet()
	ui.Text( "Looking for information" )
end

function FindInformation:CalculateUtility( actor )
	return UTILITY.HABIT
end

function FindInformation:Interact( actor )
	-- Look for a place to snoop.
	local dest
	local function IsTavern( x, depth )
		if x:HasAspect( Feature.Tavern ) then
			dest = x
		end
		return depth < 6, dest ~= nil
	end

	actor.location:Flood( IsTavern )
	if dest then
		self.travel:DoVerb( actor, dest )
	end

	Msg:Speak( actor, "Psst. Hear anything interesting?" )
	self.idle:DoVerb( actor )
end


---------------------------------------------------------------------

local Snoop = class( "Agent.Snoop", Agent )

Snoop.MAP_CHAR = "s"
Snoop.unfamiliar_desc = "snoop"

function Snoop:init()
	Agent.init( self )

	self:MakeHuman()

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.FindInformation( self ))
end

function Snoop:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Here's a guy.", GENDER.MALE )
end
