local LootObject = class( "Verb.LootObject", Verb )

function LootObject:GetActDesc( actor )
	return loc.format( "Get {1}", tostring(self.obj))
end

function LootObject:CanInteract( actor, obj )
	if obj:GetCarrier() then
		if is_instance( obj:GetCarrier().owner, Agent ) and not obj:GetCarrier().owner:IsDead() then
			return false, "Already carried"
		end

	elseif obj:GetCarrier() == nil then
		if not actor:CanReach( obj ) then
			return false, "Can't reach"
		end
	end
	if obj.mass > actor:CalculateStat( CORE_STAT.STRENGTH ) then
		return false, loc.format( "Too heavy (Need {1} {2})", obj.mass, CORE_STAT.STRENGTH )
	end

	if not obj:GetAspect( Aspect.Carryable ) then
		return false -- Not even carryable
	end
	return true
end

function LootObject:Interact( actor, obj )

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

function LootAll:init( inventory )
	Verb.init( self, nil, inventory )
	self.inventory = inventory
end

function LootAll:Interact( actor, inventory )
	inventory = inventory or self.inventory

	self.loot = self.loot or Verb.LootObject()

	local items = table.shallowcopy( inventory:GetItems() )
	for i, obj in ipairs( items ) do
		local wearable = obj:GetAspect( Aspect.Wearable )
		if wearable and wearable:IsEquipped() then
			Msg:EchoTo( actor, "You remove {1} from {2.desc}.", obj:GetName(), inventory.owner:LocTable( actor ))
			wearable:Unequip()
		end

		print( "LootAll", self:DoChildVerb( self.loot, obj ))
	end
end
