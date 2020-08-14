local LootObject = class( "Verb.LootObject", Verb )

function LootObject:init( actor, obj )
	Verb.init( self, actor )
	assert( is_instance( obj, Object ))
	self.obj = obj
end

function LootObject:GetActDesc()
	return loc.format( "Get {1}", tostring(self.obj))
end

function LootObject:CanInteract()
	local actor, obj = self.actor, self.obj
	if obj:GetCarrier() then
		if is_instance( obj:GetCarrier().owner, Agent ) and not obj:GetCarrier().owner:IsDead() then
			return false, "Already carried"
		end

	elseif obj:GetCarrier() == nil then
		if not actor:CanReach( obj ) then
			return false, "Can't reach"
		end
	end

	local ok, reason = actor:CanCarry( obj )
	if not ok then
		return false
	end

	return true
end

function LootObject:Interact()
	local actor, obj = self.actor, self.obj
	Msg:EchoTo( actor, "You pick up {1}.", obj:GetName( actor ))
	Msg:EchoAround( actor, "{1.desc} picks up {2.desc}.", actor, obj )

	if obj:GetCarrier() == nil then
		obj:WarpToNowhere()
		actor:GetInventory():AddItem( obj )
	else
		obj:GetCarrier():TransferItem( obj, actor:GetInventory() )
	end
end

-------------------------------------------------------------

local LootAll = class( "Verb.LootAll", Verb )
LootAll.act_desc = "Loot all"

function LootAll:init( actor, inventory )
	Verb.init( self, actor )
	self.inventory = inventory
end

function LootAll:Interact()
	local actor, inventory = self.actor, self.inventory

	local items = table.shallowcopy( inventory:GetItems() )
	for i, obj in ipairs( items ) do
		local wearable = obj:GetAspect( Aspect.Wearable )
		if wearable and wearable:IsEquipped() then
			Msg:EchoTo( actor, "You remove {1} from {2.desc}.", obj:GetName(), inventory.owner:LocTable( actor ))
			wearable:Unequip()
		end

		print( "LootAll", self:DoChildVerb( Verb.LootObject( actor,obj )))
	end
end
