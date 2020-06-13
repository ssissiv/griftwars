
local LootTable = class( "LootTable" )

function LootTable:GenerateLoot( rng )
	local fn = rng:WeightedPick( self.loot )
	local items = { fn( rng or world.rng ) }
	return items
end


function LootTable:SpawnLoot( inv, rng )
	local items = self:GenerateLoot( rng )
	for i, obj in ipairs( items ) do
		inv:AddItem( obj )
	end
	return items
end

------------------------------------------------------------------

local JunkT1 = class( "LootTable.JunkT1", LootTable )
JunkT1.name = "JUNK_T1"
JunkT1.loot =
{
	function( rng )
		return Object.Creds( rng( 1, 3 ))
	end, 1,
	function()
		return Object.Jerky()
	end, 1,
	nil_function, 5,
}
LOOT_JUNK_T1 = JunkT1()

local JunkT2 = class( "LootTable.JunkT2", LootTable )
JunkT2.name = "JUNK_T2"
JunkT2.loot =
{
	function( rng )
		return Object.Creds( rng( 1, 3 ))
	end, 1,
	function( rng )
		return Object.Creds( rng( 3, 5 ))
	end, 1,
	function()
		return Object.Jerky()
	end, 1,
	nil_function, 3,
}
LOOT_JUNK_T2 = JunkT2()

local JunkT3 = class( "LootTable.JunkT3", LootTable )
JunkT3.name = "JUNK_T3"
JunkT3.loot =
{
	function( rng )
		return Object.Creds( rng( 2, 4 ))
	end, 1,
	function( rng )
		return Object.Creds( rng( 6, 8 ))
	end, 1,
	function()
		return Object.Jerky(), Object.Jerky()
	end, 1,
	nil_function, 2,
}
LOOT_JUNK_T3 = JunkT3()

local Berries = class( "LootTable.Berries", LootTable )
Berries.name = "BERRIES"
Berries.loot =
{
	function()
		return Object.Berries()
	end, 1,
	nil_function, 1,
}
LOOT_BERRIES = Berries()

local GiftScavenger = class( "LootTable.GiftScavenger", LootTable )
GiftScavenger.name = "GIFT_SCAVENGER"
GiftScavenger.loot =
{
	function()
		return Object.Jerky(), Object.Jerky()
	end, 1,
	function()
		return Weapon.Dirk()
	end, 1,
	function()
		return Weapon.JaggedDirk()
	end, 1,
}
LOOT_GIFT_SCAVENGER = GiftScavenger()

