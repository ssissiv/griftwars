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
	Deliver._base.init( self, giver )
	self.giver = giver
	self.receiver = receiver
	self.travel = Verb.Travel( self.giver, self.receiver )
end

function Deliver:CalculateUtility( actor )
	if self:DidWithinTime( actor, ONE_DAY ) then
		return -1
	end

	return self.utility + 1
end

function Deliver:CanInteract( actor )
	-- if actor:GetInventory():CalculateValue() < 5 then
	-- 	return false, "Nothing to deliver"
	-- end
	return true
end

function Deliver:Interact( actor )
	self:DoChildVerb( self.travel )

	Verb.GiveAll.Interact( nil, actor, self.receiver )

	actor:LoseAspect( self )
end
