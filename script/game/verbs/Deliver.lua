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
	self.travel = self:AddChildVerb( Verb.Travel( self.giver, self.receiver ))
end

function Deliver:GetShortDesc( viewer )
	if viewer == self.giver then
		return loc.format( self.ACT_DESC[1], nil, self.receiver:LocTable( viewer ))
	elseif viewer == self.receiver then
		return loc.format( self.ACT_DESC[2], self.actor:LocTable( viewer ), self.receiver:LocTable( viewer ))		
	else
		return loc.format( self.ACT_DESC[3], self.actor:LocTable( viewer ), self.receiver:LocTable( viewer ))
	end
end


function Deliver:UpdatePriority( actor, priority )
	if self:DidWithinTime( actor, ONE_DAY ) then
		return -1
	end

	return priority + 1
end

function Deliver:CanInteract( actor )
	-- if actor:GetInventory():CalculateValue() < 5 then
	-- 	return false, "Nothing to deliver"
	-- end
	return true
end

function Deliver:Interact( actor )
	self.travel:DoVerb( actor )

	Verb.GiveAll.Interact( nil, actor, self.receiver )

	actor:GetAspect( Aspect.Behaviour ):UnregisterVerb( self )
	self.removed = true -- FIXME.
end
