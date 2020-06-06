local Inventory = class( "Aspect.Inventory", Aspect )

function Inventory:init()
	self.items = {}
end

function Inventory:OnSpawn( world )
	Aspect.OnSpawn( self, world )
	for i, obj in ipairs( self.items ) do
		world:SpawnEntity( obj )
	end
end

function Inventory:OnDespawn()
	self:ClearItems()
	Aspect.OnDespawn( self )
end

function Inventory:ClearItems()
	if self:IsSpawned() then
		for i, obj in ipairs( self.items ) do
			self:GetWorld():DespawnEntity( obj )
		end
	end
	table.clear( self.items )	
end

function Inventory:IsEmpty()
	return #self.items == 0
end

function Inventory:GetMoney()
	return self.money and self.money:GetValue() or 0
end

function Inventory:DeltaMoney( delta )
	if self.money then
		self.money:DeltaValue( delta )

		if self.money:GetValue() == 0 then
			self:RemoveItem( self.money )
		end

	elseif delta > 0 then
		self.money = Object.Creds( delta )
		self:AddItem( self.money )
	end
end

function Inventory:CalculateValue()
	local value = 0
	for i, item in ipairs( self.items ) do
		value = value + item:GetValue()
	end
	return value
end

function Inventory:AddItem( item )
	-- TODO: do item merging

	table.insert( self.items, item )
	item:AssignCarrier( self )

	if self:IsSpawned() and not item:IsSpawned() then
		self:GetWorld():SpawnEntity( item )
	end
end

function Inventory:RemoveItem( item )
	assert( self.slots == nil or not table.find( self.slots, item ), "Object not deallocated from slot" )

	item:AssignCarrier( nil )
	table.arrayremove( self.items, item )

	if item == self.money then
		self.money = nil
	end
end

function Inventory:TransferMoney( amount, target )
	self:DeltaMoney( -amount )
	target:GetInventory():DeltaMoney( amount )
end

function Inventory:TransferItem( item, inventory )
	-- Don't use RemoveItem -- we are reassigning, not despawning.
	assert( self.slots == nil or not table.find( self.slots, item ), "Object not deallocated from slot" )
	table.arrayremove( self.items, item )

	if item == self.money then
		self.money = nil
	end

	inventory:AddItem( item )
end

function Inventory:TransferAll( inventory )
	while #self.items > 0 do
		self:TransferItem( self.items[ #self.items ], inventory )
	end
end

function Inventory:AccessSlot( slot )
	return self.slots and self.slots[ slot ]
end

function Inventory:AllocateSlot( slot, obj )
	assert( IsEnum( slot, EQ_SLOT ))
	assert( table.contains( self.items, obj ))
	if self.slots == nil then
		self.slots = {}
	end

	assert( self.slots[ slot ] == nil )
	self.slots[ slot ] = obj
end

function Inventory:DeallocateSlot( slot, obj )
	assert( IsEnum( slot, EQ_SLOT ))
	assert( table.contains( self.items, obj ))
	assert( self.slots[ slot ] == obj )
	self.slots[ slot ] = nil
end

function Inventory:GetRandomItem()
	return table.arraypick( self.items )
end

function Inventory:GetItems()
	return self.items
end

function Inventory:Items()
	return ipairs( self.items )
end

function Inventory:CollectVerbs( verbs, actor, target )
	if self.items then
		for i, obj in ipairs( self.items ) do
			if obj ~= target then
				verbs:CollectVerbsFromEntity( obj, actor, target )
			end
		end
	end
end

function Inventory:RenderDebugPanel( ui, panel, dbg )
	for i, item in ipairs( self.items ) do
		panel:AppendTable( ui, item )
		if self.slots then
			local slot = table.find( self.slots, item )
			if slot then
				ui.SameLine( 0, 10 )
				ui.TextColored( 0, 200, 200, 255, tostring(slot))
			end
		end
	end
end
