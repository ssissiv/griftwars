local Want = class( "Verb.Want", Verb )

function Want:CollectVerbs( verbs, actor )
	verbs:AddVerb( self )
end

-------------------------------------------------------

local WantMoney = class( "Want.Money", Verb.Want )

function WantMoney:init( amount )
	Verb.Want.init( self )
	self.amount = amount
end

function WantMoney:GetActDesc()
	return loc.format( "Offer {1#money}", self.amount )
end

function WantMoney:CanInteract( actor )
	if actor:GetInventory():GetMoney() < self.amount then
		return false, "Not enough money"
	end

	return Verb.CanInteract( self, actor )
end

function WantMoney:Interact( actor )
	self:DoChildVerb( Verb.GiveMoney(), self.owner, self.amount )
	self.owner:DeltaTrust( 10, actor )
end

-------------------------------------------------------

local WantObject = class( "Want.Object", Verb.Want )

function WantObject:init( class_name )
	Verb.Want.init( self )
	self.class_name = class_name
end


