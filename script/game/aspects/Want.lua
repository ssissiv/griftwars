local Want = class( "Verb.Want", Verb )

function Want:CollectVerbs( verbs, actor, obj )
	if obj == self.owner and actor:KnowsAspect( self ) then
		local v = self:Clone()
		v.actor = actor
		verbs:AddVerb( v )
	end
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

function WantMoney:CanInteract()
	if self.actor:GetInventory():GetMoney() < self.amount then
		return false, "Not enough money"
	end

	return Verb.CanInteract( self )
end

function WantMoney:Interact()
	self:DoChildVerb( Verb.GiveMoney( self.actor, self.owner, self.amount ))
	self.owner:DeltaTrust( 10, self.actor )
end

-------------------------------------------------------

local WantObject = class( "Want.Object", Verb.Want )

function WantObject:init( class_name )
	Verb.Want.init( self )
	self.class_name = class_name
end


