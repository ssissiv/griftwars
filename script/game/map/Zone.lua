local Zone = class( "Zone", Entity )

function Zone:init( worldgen )
	self.worldgen = worldgen
end

function Zone:OnSpawn( world )
	Entity.OnSpawn( self, world )

	if self.rooms == nil then
		self.rooms = {}
		self:GenerateZone()
	end
end

