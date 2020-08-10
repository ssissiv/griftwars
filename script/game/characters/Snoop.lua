
local FindInformation = class( "Verb.FindInformation", Verb.Plan )

function FindInformation:init( actor )
	FindInformation._base.init( self, actor )
	self.travel = Verb.Travel( actor )
	self.idle = Verb.Idle( actor )
	self.wander = Verb.Wander( actor )
end

function FindInformation:GetDesc( ui, screen, viewer )
	return "Looking for information"
end

function FindInformation:CalculateUtility()
	return UTILITY.HABIT
end

function FindInformation:Interact()
	local actor = self.actor
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
		self.travel:SetDest( dest )
		self:DoChildVerb( self.travel )
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

	self:GainAspect( Verb.FindInformation( self ))
end

function Snoop:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Here's a guy.", GENDER.MALE )
end
