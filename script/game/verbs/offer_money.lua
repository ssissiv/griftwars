
local OfferMoney = class( "Verb.OfferMoney", Verb )
OfferMoney.STRINGS =
{
	"You give {2.name} {3#money}.",
	"{1.name} gives you {3#money}. Wonderful!",
	"{1.name} gives {2.name} some money.",
}

function OfferMoney:GetDesc( obj )
	if obj then
		return loc.format( "Give {1#money}", obj:GetPrestige() )
	else
		return "Give some money"
	end
end

function OfferMoney:CanInteract( actor, obj )
	if obj then
		local cost = obj:GetPrestige()
		if actor:GetInventory():GetMoney() < cost then
			return false, loc.format( "Requires at least {1#money}.", cost )
		else
			return true, loc.format( "Cost: {1#money}\n{2} will like you.", cost, obj:GetName() )
		end
	end
	return false
end

function OfferMoney:Interact( actor, obj )
	local delta = obj:GetPrestige()
	actor:GetInventory():DeltaMoney( -delta )
	obj:GetInventory():DeltaMoney( delta )

	Msg:Action( self.STRINGS, actor, obj, delta )

	obj:GetSocialNode():ImproveRelationship( actor )
end