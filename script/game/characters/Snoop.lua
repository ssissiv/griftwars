
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
	while true do
		local dest = actor.location:FloodFindLocalTavern()
		if dest and not actor:GetLocation() == dest then
			self.travel:SetDest( dest )
			self:DoChildVerb( self.travel )
		end

		if self:IsCancelled() then
			break
		end

		if actor:GetLocation() == dest then
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
	self:DeltaLevel( math.random( 1, 3 ))
end

function Snoop:OnSpawn( world )
	Agent.OnSpawn( self, world )
	self:SetDetails( nil, "Here's a guy.", GENDER.MALE )
end
