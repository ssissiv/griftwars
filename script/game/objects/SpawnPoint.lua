local SpawnPoint = class( "Object.SpawnPoint", Object )

function SpawnPoint:CountSpawns()
	local count = 0
	for i, obj in self.location:Contents() do
		if is_instance( obj, self.spawn_class ) then
			count = count + 1
		end
	end
	return count
end

function SpawnPoint:OnTickUpdate()
	local count = self:CountSpawns()
	if count < self.spawn_max then
		self.spawn_class():WarpToLocation( self.location, self:GetCoordinate() )
	end
end
