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

function Chest:SpawnLoot( loot_table )
	loot_table:SpawnLoot( self.inv, self.rng )
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
			verbs:AddVerb( Verb.LootInventory( actor, self.inv ))
			verbs:AddVerb( Verb.CloseObject( actor, self ))
		else
			verbs:AddVerb( Verb.OpenObject( actor, self ))
		end
	end
end
