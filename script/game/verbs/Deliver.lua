-------------------------------------------------------------
-- giver travels to receiver's location, and gives inventory

local Deliver = class( "Verb.Deliver", Verb )

Deliver.ACT_DESC =
{
	"You are here delivering to {2.Id}.",	
	"{1.Id} is here delivering something to you.",
	"{1.Id} is here delivering something to {2.Id}.",
}


function Deliver:init( giver, receiver )
	Verb.init( self, giver, receiver )
	self.giver = giver
	self.receiver = receiver
end

function Deliver:Interact( actor )
	self.travel = Verb.Travel( self.giver, self.receiver )
	self.travel:Interact( self.giver )

	if self.giver:GetLocation() == self.receiver:GetLocation() then
		Msg:ActToRoom( "{1.Id} gives something to {2.Id}.", self.giver, self.receiver )
		for i, item in self.giver:GetInventory():Items() do		
			Msg:Echo( self.giver, "You give {1} to {2.Id}.", item, self.receiver )
			Msg:Echo( target, "{1.Id} gives you {2}.", self.giver, item )
		end
	end
end
