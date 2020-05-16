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
	for i, obj in ipairs( self.items ) do
		world:DespawnEntity( obj )
	end
	table.clear( self.items )

	Aspect.OnDespawn( self )
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
			table.arrayremove( self.items, self.money )
			self.money = nil
		end

	elseif delta > 0 then
		self.money = Object.Creds()
		self.money:DeltaValue( delta )

		table.insert( self.items, self.money )
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
	item:AssignOwner( self )

	if self:IsSpawned() and not item:IsSpawned() then
		self:GetWorld():SpawnEntity( item )
	end
end

function Inventory:RemoveItem( item )
	assert( item ~= self.money )
	table.arrayremove( self.items, item )

	if self:IsSpawned() then
		self.world:DespawnEntity( item )
	end
end

function Inventory:TransferItem( item, inventory )
	table.arrayremove( self.items, item )
	inventory:AddItem( item )
	if item == self.money then
		self.money = nil
	end
end

function Inventory:TransferAll( inventory )
	while #self.items > 0 do
		self:TransferItem( self.items[ #self.items ], inventory )
	end
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

function Inventory:CollectVerbs( verbs, actor, obj )
	if obj == self.owner then
		if is_instance( self.owner, Agent ) and self.owner:IsDead() and not self:IsEmpty() then
			verbs:AddVerb( Verb.LootInventory( self ) )
		end
	end
end

function Inventory:RenderDebugPanel( ui, panel, dbg )
	for i, item in ipairs( self.items ) do
		panel:AppendTable( ui, item )
	end
end
