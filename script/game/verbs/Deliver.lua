-------------------------------------------------------------
-- giver travels to receiver's location, and gives inventory

local Deliver = class( "Verb.Deliver", Verb )

Deliver.ACT_DESC =
{
	"You are here delivering to {2.Id}.",	
	"{1.Id} is here delivering something to you.",
	"{1.Id} is here delivering something to {2.Id}.",
}


function Deliver:init( actor, receiver )
	Deliver._base.init( self, giver )
	self.receiver = receiver
end

function Deliver:CalculateUtility()
	if self:DidWithinTime( actor, ONE_DAY ) then
		return -1
	end

	return self.utility + 1
end

function Deliver:CanInteract()
	-- if actor:GetInventory():CalculateValue() < 5 then
	-- 	return false, "Nothing to deliver"
	-- end
	return true
end

function Deliver:Interact()
	self:DoChildVerb( Verb.Travel( self.actor, self.receiver ))

	self:DoChildVerb( Verb.GiveAll( self.actor, self.receiver ))

	self.actor:LoseAspect( self )
end
