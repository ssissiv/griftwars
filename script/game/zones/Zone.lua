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

function Zone:GetBounds()
	local x1, y1, x2, y2 = math.huge, math.huge, -math.huge, -math.huge
	for i, room in ipairs( self.rooms ) do
		local x, y = room:GetCoordinate()
		if x and y then
			x1 = math.min( x1, x )
			x2 = math.max( x2, x )
			y1 = math.min( y1, y )
			y2 = math.max( y2, y )
		end
	end

	return x1, y1, x2, y2
end
