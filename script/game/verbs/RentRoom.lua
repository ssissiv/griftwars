
local RentRoom = class( "Verb.RentRoom", Verb )

RentRoom.can_repeat = true -- This interaction can take place multiple times.

function RentRoom:init( target, cost )
	assert( cost )
	Verb.init( self, nil, target )
	self.cost = cost
end

function RentRoom:GetActDesc( viewer )
	return loc.format( "Rent a room ({1#money})", self.cost )
end

function RentRoom:CalculateUtility()
	return UTILITY.FUN
end

function RentRoom:CanInteract( actor, target )
	if not target:IsAlert() then
		return false, "Not alert"
	end
	if actor:GetInventory():GetMoney() < self.cost then
		return false, "Can't afford"
	end

	return Verb.CanInteract( actor, target )
end

function RentRoom:CollectVerbs( verbs, actor, obj )
	if actor == self.owner and obj ~= actor and is_instance( obj, Agent ) then
		self.obj = obj
		verbs:AddVerb( self )
	end
end

function RentRoom:Interact( actor, target )
	local door = actor:GetLocation():FindInscribedEntity( "ROOM" )
	if door then
		door:Unlock()
		
		actor:GetInventory():TransferMoney( self.cost, target )
		Msg:EchoTo( actor, "You rent a room from {1.Id}.", target:LocTable( actor ))
		Msg:EchoTo( actor, "You hand over {1#money}.", self.cost )
	end
end

