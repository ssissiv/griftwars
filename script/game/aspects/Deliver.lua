-------------------------------------------------------------
-- giver travels to receiver's location, and gives inventory

local Deliver = class( "Behaviour.Deliver", Aspect.Behaviour )

Deliver.ACT_DESC =
{
	"You are here delivering to {2.Id}.",	
	"{1.Id} is here delivering something to you.",
	"{1.Id} is here delivering something to {2.Id}.",
}


function Deliver:init( giver, receiver )
	Deliver._base.init( self )
	self.giver = giver
	self.receiver = receiver
	self.travel = Verb.Travel( self.giver, self.receiver )
end

function Deliver:CalculatePriority()
	return self.priority + 1
end

function Deliver:RunBehaviour()
	self.owner:DoVerb( self.travel )

	if self.giver:GetLocation() == self.receiver:GetLocation() then
		Msg:ActToRoom( "{1.Id} gives something to {2.Id}.", self.giver, self.receiver )
		for i, item in self.giver:GetInventory():Items() do
			Msg:Echo( self.giver, "You give {1} to {2.Id}.", item, self.receiver )
			Msg:Echo( self.receiver, "{1.Id} gives you {2}.", self.giver, item )
		end
	end
end
