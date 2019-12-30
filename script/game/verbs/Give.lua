-------------------------------------------------------------
-- actor gives one item to receiver

local Give = class( "Verb.Give", Verb )

function Give:init( giver, receiver )
	Give._base.init( self, giver )
	self.giver = giver
	self.receiver = receiver
end

function Give:GetShortDesc( viewer )
	error()
end

function Give:Interact( actor, receiver, item )
	if actor:GetLocation() == receiver:GetLocation() then
		Msg:ActToRoom( "{1.Id} gives something to {2.Id}.", actor, receiver )

		Msg:Echo( actor, "You give {1} to {2.Id}.", item, receiver:LocTable() )
		Msg:Echo( receiver, "{1.Id} gives you {2}.", actor, item )
	end
end

-------------------------------------------------------------
-- actor gives multiple items to receiver

local GiveAll = class( "Verb.GiveAll", Verb )

function GiveAll:Interact( actor, receiver, item )
	if actor:GetLocation() == receiver:GetLocation() then
		Msg:ActToRoom( "{1.Id} gives some things to {2.Id}.", actor, receiver )
		for i, item in actor:GetInventory():Items() do
			Msg:Echo( actor, "You give {1} to {2.Id}.", item, receiver:LocTable() )
			Msg:Echo( receiver, "{1.Id} gives you {2}.", actor, item )
		end
	end
end

-------------------------------------------------------------
-- actor gives one item to receiver

local GiveMoney = class( "Verb.GiveMoney", Verb )

function GiveMoney:Interact( actor, receiver, amount )
	if actor:GetLocation() == receiver:GetLocation() then
		amount = math.min( actor:GetInventory():GetMoney(), amount )
		if amount > 0 then
			actor:GetInventory():DeltaMoney( -amount )
			receiver:GetInventory():DeltaMoney( amount )

			Msg:ActToRoom( "{1.Id} gives some money to {2.Id}.", actor, receiver )
			Msg:Echo( actor, "You give {1.Id} {2#money}.", receiver:LocTable(), amount )
			Msg:Echo( receiver, "{1.Id} gives you {2#money}.", actor, amount )
		end
	end
end

