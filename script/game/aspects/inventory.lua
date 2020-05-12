local Inventory = class( "Aspect.Inventory", Aspect )

function Inventory:init()
	self.money = Object.Creds()
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

function Inventory:GetMoney()
	return self.money:GetValue()
end

function Inventory:DeltaMoney( delta )
	self.money:DeltaValue( delta )
	if self.money:GetValue() == 0 then
		table.arrayremove( self.items, self.money )
	else
		table.insert_unique( self.items, self.money )
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
		if is_instance( self.owner, Agent ) and self.owner:IsDead() then
			verbs:AddVerb( Verb.LootInventory( self ) )
		end
	end
end

function Inventory:RenderDebugPanel( ui, panel, dbg )
	for i, item in ipairs( self.items ) do
		panel:AppendTable( ui, item )
	end
end
