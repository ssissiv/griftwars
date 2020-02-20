
local FindInformation = class( "Verb.FindInformation", Verb )

function FindInformation:init( actor )
	FindInformation._base.init( self, actor )
	self.travel = Verb.Travel( actor )
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
	else
		Msg:Speak( actor, "Guess I'll just snoop here..." )
	end

	-- Do it for a while, as long as valid.
	self:YieldForTime( ONE_HOUR )
end


---------------------------------------------------------------------

local Snoop = class( "Agent.Snoop", Agent )

function Snoop:init()
	Agent.init( self )

	self.species = SPECIES.HUMAN

	self:GainAspect( Aspect.Behaviour() )
	self:GainAspect( Verb.ManageFatigue( self ))
	self:GainAspect( Verb.FindInformation( self ))
end

function Snoop:GetTitle()
	return "Snoop"
end


function Snoop:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Here's a guy.", GENDER.MALE )
end
