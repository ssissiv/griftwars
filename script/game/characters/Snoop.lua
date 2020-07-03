
local FindInformation = class( "Verb.FindInformation", Verb.Plan )

function FindInformation:init()
	FindInformation._base.init( self )
	self.travel = Verb.Travel()
	self.idle = Verb.Idle()
	self.wander = Verb.Wander()
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
		self:DoChildVerb( self.travel, dest )
	end

	if not self:IsCancelled() then
		if actor:GetLocation() and actor:GetLocation():HasAspect( Feature.Tavern ) then
			Msg:Speak( actor, "Psst. Hear anything interesting?" )
			self:DoChildVerb( self.idle )
		else
			self:DoChildVerb( self.wander )
		end
	end
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
