local Chest = class( "Object.Chest", Object )
Chest.MAP_CHAR = "C"
Chest.image = assets.TILE_IMG.CHEST


function Chest:OnSpawn( world )
	Chest._base.OnSpawn( self, world )
	self.inv = self:GainAspect( Aspect.Inventory() )
	self.rng = self:GainAspect( Aspect.Rng() )
	self.opened = false
end

function Chest:GetName()
	return "Chest"
end

function Chest:GenerateLoot( loot_table )
	local fn = self.rng:WeightedPick( loot_table )
	local items = { fn() }
	for i, obj in ipairs( items ) do
		self.inv:AddItem( obj )
	end
end

function Chest:Open()
	self.opened = true
end

function Chest:Close()
	self.opened = false
end

function Chest:CollectVerbs( verbs, actor, target )
	if target == self then
		if self.opened then
			verbs:AddVerb( Verb.LootInventory( self.inv ))
			verbs:AddVerb( Verb.CloseObject( self ))
		else
			verbs:AddVerb( Verb.OpenObject( self ))
		end
	end
end
