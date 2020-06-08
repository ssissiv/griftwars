local BerryBush = class( "Object.BerryBush", Object )

BerryBush.MAP_CHAR = "%"
BerryBush.MAP_COLOUR = constants.colours.GREEN

function BerryBush:OnSpawn( world )
	BerryBush._base.OnSpawn( self, world )

	self.rng = self:GainAspect( Aspect.Rng())
	self:GainAspect( Aspect.Inventory() )
	self:GainAspect( Aspect.ScroungeTarget())
	self:GainAspect( Aspect.Impass( bit.bxor( IMPASS.ALL, IMPASS.LOS )))

	self:RefreshBush()
end

function BerryBush:RefreshBush()
	if self.rng:Random() < 0.5 then
		self:GetAspect( Aspect.Inventory ):ClearItems()
	end	
	self:GetAspect( Aspect.ScroungeTarget ):SetLootTable( LOOT_BERRIES )
	self.world:ScheduleFunction( ONE_DAY, self.RefreshBush, self )
end


function BerryBush:GetName()
	return "Berry Bush"
end

