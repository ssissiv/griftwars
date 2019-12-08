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

	if self.giver:GetLocation() == self.receiver:GetLocation() then
		Msg:Speak( self.giver, "Delivery.", self.receiver )
		Msg:ActToRoom( "{1.Id} gives something to {2.Id}.", self.giver, self.receiver )
		for i, item in self.giver:GetInventory():Items() do
			Msg:Echo( self.giver, "You give {1} to {2.Id}.", item, self.receiver:LocTable() )
			Msg:Echo( self.receiver, "{1.Id} gives you {2}.", self.giver, item )
		end
	end

	actor:GetAspect( Aspect.Behaviour ):UnregisterVerb( self )
	self.removed = true -- FIXME.
end
